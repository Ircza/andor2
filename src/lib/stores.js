
import { writable } from 'svelte/store'

export const headerPreview = writable(null)
export const activeConversation = writable(null)
export const bookmarks = writable({ games: [], boards: [], works: [] })
export const posts = writable([])
export const lightboxImage = writable(null)

// LOCAL STORAGE SYNCED STORES
// has to be a function to allow for multiple instances of the store with different names

export function getUserStore () {
  const userStore = writable(window.localStorage.user ? JSON.parse(localStorage.user) : {})
  userStore.subscribe(value => { window.localStorage.setItem('user', JSON.stringify(value)) })
  return userStore
}

export function getGameStore (game, def = {}) {
  const gameStore = writable(window.localStorage[game] ? JSON.parse(localStorage[game]) : def)
  gameStore.subscribe(value => { window.localStorage.setItem(game, JSON.stringify(value)) })
  return gameStore
}

export function getBoardStore (board, def = {}) {
  const boardStore = writable(window.localStorage[board] ? JSON.parse(localStorage[board]) : def)
  boardStore.subscribe(value => { window.localStorage.setItem(board, JSON.stringify(value)) })
  return boardStore
}
