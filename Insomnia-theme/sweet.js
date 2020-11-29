const black = "#1C2124";
const red = "#ec5f67";
const green = "#99c794";
const yellow = "#fac863";
const blue = "#6699cc";
const magenta = "#c594c5";

module.exports = {
  name: "sweet",
  displayName: "Sweet",
  theme: {
    background: {
      default: black,
      success: green,
      notice: yellow,
      warning: yellow,
      danger: red,
      surprise: magenta,
      info: blue,
    },
    foreground: {
      default: "#fff",
      success: "#fff",
      notice: "#fff",
      warning: "#fff",
      danger: "#fff",
      surprise: "#fff",
      info: "#fff",
    },
    highlight: {
      default: "rgba(216, 222, 233, 0.3)",
      xxs: "rgba(216, 222, 233, 0.05)",
      xs: "rgba(216, 222, 233, 0.1)",
      sm: "rgba(216, 222, 233, 0.2)",
      md: "rgba(65, 71, 76, 0.3)",
      lg: "rgba(65, 71, 76, 1)",
      xl: "rgba(216, 222, 233, 0.5)",
    },
    styles: {
      sidebar: {
        background: {
          default: "#181B1E",
        },
      },
      dialog: {
        background: {
          default: black,
        },
      },
      paneHeader: {
        background: {
          success: green,
          notice: yellow,
          warning: yellow,
          danger: red,
          surprise: magenta,
          info: blue,
        },
      },
      transparentOverlay: {
        background: {
          default: "rgba(27, 43, 52, 0.5)",
        },
      },
    },
  },
};
