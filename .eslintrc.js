{
  "extends": "airbnb",
  "plugins": [
    "babel",
    "react",
    "react-native"
  ],
  "parser": "babel-eslint",
  "env": {
    "es6": true,
    "jest": true
  },
  "rules": {
    // no-use-before-define collides with react-native best practices. see:
    // https://github.com/Intellicode/eslint-plugin-react-native/issues/22
    "no-use-before-define": 0,
    // variation from aibnb's config - indent by 4 spaces instead of 2 and
    // reduce max line length from 100 to 80
    "indent": [2, 4],
    "react/jsx-indent": [2, 4],
    "react/jsx-indent-props": [2, 4],
    "react/jsx-closing-bracket-location": [2, "tag-aligned"],
    "max-len": [2, 80, 4],
    // enable rules provided by react-native plugin
    "react-native/no-unused-styles": 2,
    "react-native/split-platform-components": 2,
    "react-native/no-inline-styles": 2,
    // "react-native/no-color-literals": 2,
    // enable rules provided by eslint-babel plugin
    "babel/generator-star-spacing": 1,
    "babel/new-cap": 1,
    "babel/array-bracket-spacing": 1,
    "babel/object-shorthand": 1,
    "babel/arrow-parens": 1,
    "babel/no-await-in-loop": 1
  },
  // re-configure node resolver from import plugin (used by airbnb config)
  // to allow react-native modules:
  // https://github.com/benmosher/eslint-plugin-import/issues/279
  "settings": {
    "import/resolver": {
      "node": {
        "extensions": [".js", ".android.js", ".ios.js"]
      }
    }
  }
}
