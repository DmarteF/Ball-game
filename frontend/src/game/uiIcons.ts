import { ImageSourcePropType } from 'react-native';

export type UiIconKey =
  | 'ui_achievements'
  | 'ui_ad'
  | 'ui_aura'
  | 'ui_back'
  | 'ui_boss'
  | 'ui_chest_common'
  | 'ui_chest_epic'
  | 'ui_chest_legendary'
  | 'ui_chest_rare'
  | 'ui_coin'
  | 'ui_daily_reward'
  | 'ui_effect'
  | 'ui_event'
  | 'ui_fragments'
  | 'ui_gem'
  | 'ui_infinite'
  | 'ui_inventory'
  | 'ui_key'
  | 'ui_league_neon'
  | 'ui_legendary_key'
  | 'ui_locked'
  | 'ui_menu'
  | 'ui_missions'
  | 'ui_no_ads'
  | 'ui_play'
  | 'ui_settings'
  | 'ui_skins'
  | 'ui_store'
  | 'ui_trail'
  | 'ui_upgrades'
  | 'ui_wheel';

export const UI_ICON_ASSETS: Partial<Record<UiIconKey, ImageSourcePropType>> = {
  ui_achievements: require('../../assets/ui/ui_achievements.png'),
  ui_ad: require('../../assets/ui/ui_ad.png'),
  ui_aura: require('../../assets/ui/ui_aura.png'),
  ui_back: require('../../assets/ui/ui_back.png'),
  ui_boss: require('../../assets/ui/ui_boss.png'),
  ui_chest_common: require('../../assets/ui/ui_chest_common.png'),
  ui_chest_epic: require('../../assets/ui/ui_chest_epic.png'),
  ui_chest_legendary: require('../../assets/ui/ui_chest_legendary.png'),
  ui_chest_rare: require('../../assets/ui/ui_chest_rare.png'),
  ui_coin: require('../../assets/ui/ui_coin.png'),
  ui_daily_reward: require('../../assets/ui/ui_daily_reward.png'),
  ui_effect: require('../../assets/ui/ui_effect.png'),
  ui_event: require('../../assets/ui/ui_event.png'),
  ui_fragments: require('../../assets/ui/ui_fragments.png'),
  ui_gem: require('../../assets/ui/ui_gem.png'),
  ui_infinite: require('../../assets/ui/ui_infinite.png'),
  ui_inventory: require('../../assets/ui/ui_inventory.png'),
  ui_key: require('../../assets/ui/ui_key.png'),
  ui_league_neon: require('../../assets/ui/ui_league_neon.png'),
  ui_legendary_key: require('../../assets/ui/ui_legendary_key.png'),
  ui_locked: require('../../assets/ui/ui_locked.png'),
  ui_menu: require('../../assets/ui/ui_menu.png'),
  ui_missions: require('../../assets/ui/ui_missions.png'),
  ui_no_ads: require('../../assets/ui/ui_no_ads.png'),
  ui_play: require('../../assets/ui/ui_play.png'),
  ui_settings: require('../../assets/ui/ui_settings.png'),
  ui_skins: require('../../assets/ui/ui_skins.png'),
  ui_store: require('../../assets/ui/ui_store.png'),
  ui_trail: require('../../assets/ui/ui_trail.png'),
  ui_upgrades: require('../../assets/ui/ui_upgrades.png'),
  ui_wheel: require('../../assets/ui/ui_wheel.png'),
};
