import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="llm-message"
export default class extends Controller {
  static values = {
    sortedChunks: []
  }

  static targets = ["chunks", "content"]

  #isSorting = false
  #observer

  #onMutate = (mutations) => {
    // Prevent re-entry during sorting
    if (this.#isSorting) return

    let shouldSort = false

    // Check if any mutation actually added/removed nodes
    for (const mutation of mutations) {
      if (mutation.addedNodes.length > 0 || mutation.removedNodes.length > 0) {
        shouldSort = true
        break
      }
    }

    if (!shouldSort) return

    this.#isSorting = true
    try {
      this.#sortChildren()
    } finally {
      // Always reset, even if error
      this.#isSorting = false
    }
  }

  #sortChildren() {
    const children = Array.from(this.chunksTarget.children)
      .filter(child => child.hasAttribute('data-order'))

    if (children.length === 0) return

    // Sort by data-order (numeric)
    const sorted = [...children].sort((a, b) => {
      const orderA = parseInt(a.dataset.order, 10) || 0
      const orderB = parseInt(b.dataset.order, 10) || 0
      return orderA - orderB
    })

    this.sortedChunksValue = sorted.map(s => s.innerText)

    // Get current order
    const currentOrder = children.map(child => child)

    // Only reorder if different
    if (currentOrder.every((child, i) => child === sorted[i]))  return // already sorted

  console.log("REORDERED!")

    // Reorder DOM **without remove/add** using insertBefore
    const parent = this.element

    sorted.forEach((child, index) => {
      // const currentPosition = Array.from(parent.children).indexOf(child)
      const desiredNextSibling = parent.children[index]

      if (child !== desiredNextSibling)  parent.insertBefore(child, desiredNextSibling)
    })
  }

  chunksTargetConnected() {
    this.#observer = new MutationObserver(this.#onMutate)
    this.#observer.observe(this.chunksTarget, {
      childList: true,
      subtree: false,
    })
  }

  disconnect() {
    this.#observer?.disconnect()
  }

  sortedChunksValueChanged(v) {
    if (!v || !v.length) return
  const res = v.join("")
    console.log(res)
    this.contentTarget.innerText = res
  }
}
