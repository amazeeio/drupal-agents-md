---
title: Testing & Quality Assurance
description: >
  Drupal testing with PHPUnit: Unit, Kernel, and Functional test examples.
  Covers test base classes, configuration, and code quality tools.
tags: [testing, phpunit, unit-test, kernel-test, functional-test, quality]
---

# Testing & Quality Assurance

## Running Tests
```bash
# All tests
vendor/bin/phpunit -v --coverage-html coverage/

# By suite
vendor/bin/phpunit --testsuite unit          # Fast, no Drupal
vendor/bin/phpunit --testsuite kernel         # DB + minimal Drupal
vendor/bin/phpunit --testsuite functional     # Full browser
vendor/bin/phpunit --testsuite javascript     # JS tests

# Specific test
vendor/bin/phpunit --filter MyModuleUnitTest
vendor/bin/phpunit modules/custom/my_module/tests/src/Unit/
```

## Unit Test (fastest — no Drupal bootstrap)
```php
namespace Drupal\Tests\my_module\Unit;

use Drupal\Tests\UnitTestCase;
use Drupal\my_module\Service\MyService;
use Prophecy\PhpUnit\ProphecyTrait;

class MyServiceTest extends UnitTestCase {
  use ProphecyTrait;

  public function testProcessReturnsExpectedValue(): void {
    $logger = $this->prophesize('\Psr\Log\LoggerInterface');
    $service = new MyService($logger->reveal());
    $result = $service->process('input');
    $this->assertEquals('expected_output', $result);
  }

  public function testProcessThrowsOnEmptyInput(): void {
    $logger = $this->prophesize('\Psr\Log\LoggerInterface');
    $service = new MyService($logger->reveal());
    $this->expectException(\InvalidArgumentException::class);
    $service->process('');
  }
}
```
- **Location**: `tests/src/Unit/`
- **Base class**: `Drupal\Tests\UnitTestCase`
- **Dependencies**: Mock with Prophecy

## Kernel Test (partial Drupal + in-memory DB)
```php
namespace Drupal\Tests\my_module\Kernel;

use Drupal\KernelTests\KernelTestBase;
use Drupal\node\Entity\Node;
use Drupal\node\Entity\NodeType;

class MyModuleKernelTest extends KernelTestBase {

  protected static $modules = ['system', 'node', 'user', 'my_module'];

  protected function setUp(): void {
    parent::setUp();
    $this->installEntitySchema('node');
    $this->installEntitySchema('user');
    $this->installConfig(['my_module']);
    NodeType::create(['type' => 'article', 'name' => 'Article'])->save();
  }

  public function testNodeCreation(): void {
    $node = Node::create([
      'type' => 'article',
      'title' => 'Test Article',
      'status' => 1,
    ]);
    $node->save();
    $this->assertNotNull($node->id());
    $this->assertEquals('article', $node->bundle());
  }
}
```
- **Location**: `tests/src/Kernel/`
- **Base class**: `Drupal\KernelTests\KernelTestBase`

## Functional Test (full browser simulation)
```php
namespace Drupal\Tests\my_module\Functional;

use Drupal\Tests\BrowserTestBase;

class MyModuleFunctionalTest extends BrowserTestBase {

  protected $defaultTheme = 'stark';
  protected static $modules = ['node', 'my_module'];

  protected function setUp(): void {
    parent::setUp();
    $this->drupalCreateContentType(['type' => 'article', 'name' => 'Article']);
    $user = $this->drupalCreateUser(['access content', 'create article content']);
    $this->drupalLogin($user);
  }

  public function testArticleCreation(): void {
    $this->drupalGet('/node/add/article');
    $this->assertSession()->statusCodeEquals(200);
    $this->submitForm(['title[0][value]' => 'Test Article'], 'Save');
    $this->assertSession()->pageTextContains('has been created.');
  }
}
```
- **Location**: `tests/src/Functional/`
- **Base class**: `Drupal\Tests\BrowserTestBase`

## Quality Tools
```bash
vendor/bin/phpstan analyse       # Static analysis
vendor/bin/drupal-check          # Deprecated code check
composer audit                   # Security advisories
vendor/bin/phpcs --standard=Drupal .  # Code style
```

## Related Files
- [02-code-standards.md](02-code-standards.md) — Code style rules
- [03-module-scaffolding.md](03-module-scaffolding.md) — Test directory structure
