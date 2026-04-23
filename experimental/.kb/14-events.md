---
title: Events & EventSubscribers
description: >
  Symfony EventDispatcher in Drupal: replacing hooks with event subscribers for better testability. Includes complete example with service registration.


tags: [events, event-subscriber, symfony, kernel-events]
---

# Events & EventSubscribers

Prefer EventSubscribers over hooks for many use cases. They are more testable and follow Symfony conventions.

## EventSubscriber Example

```php
namespace Drupal\my_module\EventSubscriber;

use Symfony\Component\EventDispatcher\EventSubscriberInterface;
use Symfony\Component\HttpKernel\KernelEvents;
use Symfony\Component\HttpKernel\Event\RequestEvent;

class MyEventSubscriber implements EventSubscriberInterface {

  public static function getSubscribedEvents(): array {
    return [
      KernelEvents::REQUEST => ['onKernelRequest', 100],
      KernelEvents::RESPONSE => ['onKernelResponse'],
    ];
  }

  public function onKernelRequest(RequestEvent $event): void {
    $request = $event->getRequest();
    // Act on every request.
  }

  public function onKernelResponse(\Symfony\Component\HttpKernel\Event\ResponseEvent $event): void {
    // Modify response.
  }
}
```

## Register as a Service

```yaml
# my_module.services.yml
my_module.event_subscriber:
  class: Drupal\my_module\EventSubscriber\MyEventSubscriber
  arguments: ["@current_user", "@config.factory"]
  tags:
    - { name: event_subscriber }
```

The `event_subscriber` tag is required — Drupal auto-discovers subscribers via this tag.

## Common Kernel Events

| Event                      | When                              |
| -------------------------- | --------------------------------- |
| `KernelEvents::REQUEST`    | Incoming request                  |
| `KernelEvents::RESPONSE`   | Outgoing response                 |
| `KernelEvents::EXCEPTION`  | Uncaught exception                |
| `KernelEvents::VIEW`       | Controller returns non-Response   |
| `KernelEvents::CONTROLLER` | Controller found but not executed |

## Drupal-Specific Events

The `HookEventDispatcher` contrib module provides events for most Drupal hooks (entity presave, form alter, etc.). Core also dispatches events for entity operations.

## Related Files

- [07-hooks.md](07-hooks.md) — Traditional hooks (alternative approach)
- [04-services-di.md](04-services-di.md) — Service definitions
