---
title: Forms API
description: >
  Drupal Forms API: simple forms, configuration forms, validation, submission, and AJAX patterns. Includes complete copy-pasteable examples for FormBase and ConfigFormBase.


tags: [forms, form-api, config-form, ajax-form, validation]
---

# Forms API

## Simple Form (FormBase)

```php
namespace Drupal\my_module\Form;

use Drupal\Core\Form\FormBase;
use Drupal\Core\Form\FormStateInterface;

class CustomForm extends FormBase {

  public function getFormId(): string {
    return 'my_module_custom_form';
  }

  public function buildForm(array $form, FormStateInterface $form_state): array {
    $form['email'] = [
      '#type' => 'email',
      '#title' => $this->t('Email Address'),
      '#required' => TRUE,
    ];

    $form['category'] = [
      '#type' => 'select',
      '#title' => $this->t('Category'),
      '#options' => [
        'news' => $this->t('News'),
        'events' => $this->t('Events'),
        'blog' => $this->t('Blog'),
      ],
      '#ajax' => [
        'callback' => '::categoryChanged',
        'wrapper' => 'subcategory-wrapper',
        'event' => 'change',
      ],
    ];

    $form['subcategory'] = [
      '#type' => 'container',
      '#attributes' => ['id' => 'subcategory-wrapper'],
      'value' => [
        '#type' => 'textfield',
        '#title' => $this->t('Subcategory'),
      ],
    ];

    $form['actions']['submit'] = [
      '#type' => 'submit',
      '#value' => $this->t('Submit'),
    ];

    return $form;
  }

  public function categoryChanged(array &$form, FormStateInterface $form_state): array {
    return $form['subcategory'];
  }

  public function validateForm(array &$form, FormStateInterface $form_state): void {
    $email = $form_state->getValue('email');
    if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
      $form_state->setErrorByName('email', $this->t('Please enter a valid email address.'));
    }
  }

  public function submitForm(array &$form, FormStateInterface $form_state): void {
    $this->messenger()->addStatus($this->t('Form submitted successfully.'));
    $form_state->setRedirect('<front>');
  }
}
```

## Configuration Form (ConfigFormBase)

```php
namespace Drupal\my_module\Form;

use Drupal\Core\Form\ConfigFormBase;
use Drupal\Core\Form\FormStateInterface;

class SettingsForm extends ConfigFormBase {

  public function getFormId(): string {
    return 'my_module_settings';
  }

  protected function getEditableConfigNames(): array {
    return ['my_module.settings'];
  }

  public function buildForm(array $form, FormStateInterface $form_state): array {
    $config = $this->config('my_module.settings');

    $form['api_key'] = [
      '#type' => 'textfield',
      '#title' => $this->t('API Key'),
      '#default_value' => $config->get('api_key'),
      '#required' => TRUE,
    ];

    $form['max_items'] = [
      '#type' => 'number',
      '#title' => $this->t('Maximum Items'),
      '#default_value' => $config->get('max_items') ?? 50,
      '#min' => 1,
      '#max' => 500,
    ];

    return parent::buildForm($form, $form_state);
  }

  public function submitForm(array &$form, FormStateInterface $form_state): void {
    $this->config('my_module.settings')
      ->set('api_key', $form_state->getValue('api_key'))
      ->set('max_items', $form_state->getValue('max_items'))
      ->save();

    parent::submitForm($form, $form_state);
  }
}
```

## AJAX Forms Quick Reference

- Add `#ajax` property to any form element
- Callback: `'::methodName'` syntax
- Wrapper: target element ID for replacement
- Events: `'change'`, `'click'`, `'blur'`
- Trigger: `$form_state->getTriggeringElement()`
- Error handling: try-catch in callbacks

## Related Files

- [09-routes-controllers.md](09-routes-controllers.md) — Routing forms to paths
- [15-configuration.md](15-configuration.md) — Config storage details
- [17-render-api.md](17-render-api.md) — Render arrays used in forms
