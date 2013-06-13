class DesignAddonToPackage

  MAP = {
    classic: {
      controls: 'player-controls',
      lightbox: 'lightbox',
      logo: 'logo'
    },
    flat: {
      controls: 'player-controls',
      lightbox: 'lightbox',
      logo: 'logo'
    },
    light: {
      controls: 'player-controls',
      lightbox: 'lightbox',
      logo: 'logo'
    }
  }

  def self.package(design, addon)
    MAP[design.to_sym][addon.to_sym]
  end

end
