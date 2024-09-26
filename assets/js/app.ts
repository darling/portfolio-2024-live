// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import { Socket } from "phoenix"
import { LiveSocket } from "phoenix_live_view"

import Hooks from "./hooks"

let csrfToken = document.querySelector("meta[name='csrf-token']")?.getAttribute("content");
let liveSocket = new LiveSocket("/live", Socket, {
  longPollFallbackMs: 2500,
  params: { _csrf_token: csrfToken },
  hooks: Hooks
})

// connect if there are any LiveViews on the page
liveSocket.connect()

declare global {
  interface Window {
    liveSocket: LiveSocket
  }
}

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket

export function updateSongs(songs: unknown) {
  const songsList = document.getElementById("music-results-songs-list");
  const existingItems = songsList?.querySelectorAll("li");

  if (songsList && existingItems) {
    existingItems.forEach(item => {
      item.classList.add("opacity-0");
    });

    setTimeout(() => {
      liveSocket.execJS(songsList, JSON.stringify([
        ["stream", "songs", songs]
      ]));
    }, 300);
  }
}
