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
