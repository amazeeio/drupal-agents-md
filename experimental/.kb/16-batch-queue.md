---
title: Batch API & Queue API
description: >
  Processing large datasets and background tasks in Drupal. Batch API for
  user-facing long operations with progress bars. Queue API for cron-based
  background processing with QueueWorker plugins.
tags: [batch, queue, queue-worker, cron, background-processing]
---

# Batch API & Queue API

## Batch API (user-facing long operations)

```php
use Drupal\Core\Batch\BatchBuilder;

function my_module_process_items(array $items): void {
  $batch = (new BatchBuilder())
    ->setTitle(t('Processing items'))
    ->setInitMessage(t('Initializing...'))
    ->setProgressMessage(t('Processed @current out of @total.'))
    ->setErrorMessage(t('An error occurred during processing.'))
    ->setFile(\Drupal::service('extension.list.module')->getPath('my_module') . '/my_module.batch.inc')
    ->setFinishCallback('my_module_batch_finished')
    ->addOperation('my_module_batch_process', [$items]);

  batch_set($batch->toArray());
}
```

```php
// my_module.batch.inc
function my_module_batch_process(array $items, array &$context): void {
  if (!isset($context['sandbox']['progress'])) {
    $context['sandbox']['progress'] = 0;
    $context['sandbox']['max'] = count($items);
    $context['sandbox']['items'] = $items;
  }

  $limit = 10;
  $items_to_process = array_slice($context['sandbox']['items'], $context['sandbox']['progress'], $limit);

  foreach ($items_to_process as $item) {
    // Process each item.
    $context['sandbox']['progress']++;
  }

  $context['finished'] = $context['sandbox']['progress'] / $context['sandbox']['max'];
  $context['message'] = t('Processed @progress of @max', [
    '@progress' => $context['sandbox']['progress'],
    '@max' => $context['sandbox']['max'],
  ]);
}

function my_module_batch_finished(bool $success, array $results, array $operations): void {
  $messenger = \Drupal::messenger();
  if ($success) {
    $messenger->addStatus(t('Batch completed successfully.'));
  }
  else {
    $messenger->addError(t('An error occurred during batch processing.'));
  }
}
```

**Use cases**: Data migration, bulk updates, file processing, API calls.

## Queue API (background processing)

### QueueWorker Plugin
```php
namespace Drupal\my_module\Plugin\QueueWorker;

use Drupal\Core\Queue\QueueWorkerBase;
use Drupal\Core\Plugin\ContainerFactoryPluginInterface;
use Symfony\Component\DependencyInjection\ContainerInterface;

/**
 * @QueueWorker(
 *   id = "my_module_processor",
 *   title = @Translation("My Module Processor"),
 *   cron = {"time" = 60}
 * )
 */
class MyQueueWorker extends QueueWorkerBase implements ContainerFactoryPluginInterface {

  public static function create(ContainerInterface $container, array $configuration, $plugin_id, $plugin_definition): static {
    return new static($configuration, $plugin_id, $plugin_definition);
  }

  public function processItem($data): void {
    if (!isset($data['type'])) {
      throw new \InvalidArgumentException('Missing type in queue item.');
    }
    // Process the item...
  }
}
```

### Adding Items to Queue
```php
\Drupal::queue('my_module_processor')->createItem(['type' => 'cleanup', 'node_id' => 123]);
```

- `cron = {"time" = 60}` — processes items during cron for up to 60 seconds
- Failed items are released back to the queue automatically
- Always log queue processing outcomes

## Related Files
- [06-plugins.md](06-plugins.md) — Plugin system
- [07-hooks.md](07-hooks.md) — hook_cron() for triggering queues
