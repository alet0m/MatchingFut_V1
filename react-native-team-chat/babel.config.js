module.exports = function(api) {
  api.cache(true);
  return {
    presets: ['babel-preset-expo'],
    // Reanimated plugin disabled for this demo to avoid Expo SDK 51 plugin crash during startup.
    // If you need Reanimated animations here, re-enable it as the LAST plugin:
    // plugins: ['react-native-reanimated/plugin']
  };
};
