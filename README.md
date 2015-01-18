# SuperStack
 [![Build Status](https://travis-ci.org/lbriais/super_stack.svg)](https://travis-ci.org/lbriais/super_stack)
 [![Gem Version](https://badge.fury.io/rb/super_stack.svg)](http://badge.fury.io/rb/super_stack)

The purpose of this gem is to provide a simple way to manage the merge of different
hashes (layers) according to priority and different merge policies.

## Installation

Add this line to your application's Gemfile:

    gem 'super_stack'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install super_stack

## Usage

### Create a manager

The manager contains your different layers (hashes basically), allows you to set priorities among them, and provides
a policy to merge them.

To use the manager, you just need to:

```ruby
require 'super_stack'

manager = SuperStack::Manager.new
```

This is from the manager, that you will get the result of the merge of the different layers. Use `manager[]` to access
the result of the merge of all layers as a hash. It will be done according to the priority the layers have and the merge
policy chosen.

You can directly access to a particular key of the resulting merging by simply doing `manager[:your_key]` like you would
do with a hash. (`manager` itself has no `Hash` in its ancestors, whereas `manager[]` *is* actually a `Hash`).

**None of the layers is modified by the manager**.


### Layers

Layers are actually simple hashes that include the `SuperStack::LayerWrapper` module. Therefore you can create a layer by
different means:

* by invoking `SuperStack::Layer.new`. You can use you all options you would use on a hash.
* by calling `SuperStack::LayerWrapper.from_hash(your_hash)`. That will just add the module `SuperStack::LayerWrapper`
  to your hash.
* by adding manually adding the module to your hash (`your_hash.extend SuperStack::LayerWrapper`), which is strictly
  equivalent to the previous method.

When you create a new layer from scratch or by extending your own hash, it has automatically a name assigned, and no
particular priority. but as soon as it is added to a manager by doing either `manager << your_hash_or_layer` or
`manager.add_layer(your_hash_or_layer)`, it will see its name automatically changed (numbers automatically added) **if
the name conflicts with another layer already handled by the manager**.

You can notice by the way that it gives a third way to create a layer from a hash, as when adding a hash to a manager,
it automatically adds the `SuperStack::LayerWrapper` module to the hash.

Layers can be populated from a file anytime using the `load` method:

```ruby
layer = SuperStack::Layer.new.load 'a_file_somewhere'
# Once loaded you can get the file name used to load the layer anytime
puts layer.file_name
# And you can load or reload the layer
layer.has_file? # => true
layer.load
layer.reload
```

On top of this you can reload all the layers which have an associated file at once using the manager. If a layer has
no associated `file_name`, it won't be altered.

```ruby
layer1 = SuperStack::Layer.new.load 'a_file_somewhere'
layer1 = SuperStack::Layer.new.load 'another_file_somewhere'
manager = SuperStack::Manager.new

manager << layer1
manager << layer2

manager.reload_layers
```


### Merge policies

You can get the list of merge policies by doing `SuperStack::MergePolicies.list`, but basically, four types currently
exist:

* `SuperStack::MergePolicies::KeepPolicy`, that when merging two layers will keep the first one (the one you are merging
  to).
* `SuperStack::MergePolicies::OverridePolicy`, that when merging two layers will keep the second one(the one you are
  merging with).
* `SuperStack::MergePolicies::StandardMergePolicy`, that will perform the ruby standard `Hash#merge` method. There are
  a lot of limitations with it (like not recursive, not merging arrays within hash etc... read ruby doc for more).
  **This is the default merge method**
* `SuperStack::MergePolicies::FullMergePolicy` is actually using the [deep_merge gem][DMG] to merge two hashes. It is
  fully merging two hashes including arrays etc... Only when two types are incompatible (like Array replacing a String),
  the second one replaces the first. Much more complete implementation than the one in ActiveSupport. The way it is used
  in the gem is compliant with both the plain Ruby and the Rails implementations (see [the documentation][DMGithub])

The manager has a `default_merge_policy`, but each layer can have its own `merge_policy`. By default the internal merge
process will use the `default_merge_policy` except if a layer specifies its own.

In most cases you will just have to set the merge policy at the manager level using `default_merge_policy=`.

The alternative is to set the policy at the layer level using `merge_policy=`

## Contributing

1. Fork it ( http://github.com/lbriais/super_stack/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request


[DMG]:      https://rubygems.org/gems/deep_merge        "Deep Merge gem"
[DMGithub]: https://github.com/danielsdeleo/deep_merge  "Deep Merge Github project"

