## settings.rb in a package
```ruby
require 'package_settings'

settings = PackageSettings.new

settings[0][:name] = 'sublime'
settings[0][:template] = {
  enable: {
    type: 'boolean',
    values: [true],
    default: true
  },
  type: {
    type: 'string',
    values: ['sv'],
    default: 'sv'
  }
}

settings[1][:name] = 'disabled'
settings[1][:template] = {
  enable: {
    type: 'boolean',
    values: [true, false],
    default: false
  },
  type: {
    type: 'string',
    values: ['sv'],
    default: 'sv'
  }
}

settings[2][:name] = 'custom'
settings[3][:template] = {
  enable: {
    type: 'boolean',
    values: [true, false],
    default: true
  },
  type: {
    type: 'string',
    values: ['sv', 'custom'],
    default: 'custom'
  }
}

settings
```

## settings.js
```javascript
allowed['logo'] = {
  enable: [true],
  type: ['sv']
}

kits['1']['config']['logo'] = {
  enable: false,
  type: 'custom'
}
```

## settings.rb in lightbox package
```ruby
require 'package_settings'

settings = PackageSettings.new

settings[0][:name] = 'standard'
settings[0][:template] = {
  enable: {
    type: boolean,
    values: [true, false],
    default: true
  },
  close_button: {
    type: boolean,
    values: [true, false],
    default: true
  },
  position: {
    type: string,
    values: ['left', 'right'],
    default: 'left
  }
}

settings
```

## settings.rb in light.lightbox package
```ruby
require 'package_settings'

settings = PackageSettings.new('lightbox')

settings.get_level(1).delete_key(:close_button)

settings
```

## settings.js
```javascript
allowed['classic.controls'] = {
  enable: [true],
  type: ['sv']
}

allowed['light.controls'] = {
  enable: [true],
  type: ['sv']
}

allowed['logo'] = {
  enable: [true],
  type: ['sv']
}

kits['1']['config']['logo'] = {
  type: 'custom',
  position: 'top-left'
}
```