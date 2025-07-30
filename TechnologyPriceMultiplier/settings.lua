data:extend({
  {
    type = "double-setting",
    name = "TechnologyPriceMultiplier-price-factor",
    setting_type = "startup",
    default_value = 1.0,
    order = "0"
  },
  {
    type = "double-setting",
    name = "TechnologyPriceMultiplier-price-exponent-factor",
    setting_type = "startup",
    default_value = 1.0,
    order = "1"
  },
  {
    type = "double-setting",
    name = "TechnologyPriceMultiplier-price-tier-scaling-factor",
    setting_type = "startup",
    default_value = 1.0,
    minimum_value = 0.1,
    order = "2"
  },
  {
    type = "double-setting",
    name = "TechnologyPriceMultiplier-price-tier-scaling-curve",
    setting_type = "startup",
    default_value = 1.0,
    minimum_value = 0.1,
    order = "3"
  }
})
