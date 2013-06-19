class DesignAddonToPackage

  MAP = {
    classic: {
      controls: 'classic-player-controls',
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
    },
    sony: {
      controls: 'sony-player',
      lightbox: 'sony-player',
      logo: 'sony-player'
    }
  }

  def self.package(design, addon)
    MAP[design.to_sym][addon.to_sym]
  end

end
