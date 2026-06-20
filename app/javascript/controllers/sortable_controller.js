import { Controller } from "@hotwires/stimulus";

export default class extends Controller {
  static values = { url: String }

  connect() { this.draggedItem = null }

  dragstart(event) {
    this.draggedItem = event.currentTarget
    event.dataTransfer.effectAllowed = "move"
    event.currentTarget.classList.add("opacity-50")
  }

  dragend(event) {
    event.currentTarget.classList.remove("opacity-50")
    this.save()
  }

  dragover(event) {
    event.preventDefault()
    const target = event.currentTarget
    if (target === this.draggedItem) return 
    const rect = target.getBoundingClientRect()
    const after = event.clientY > rect.top + rect.height / 2
    target.parentNode.insertBefore(this.draggedItem, after ? target.nextSiblin : target)
  }

  drop(event) { event.preventDefault() }

  save() {
    const ids = Array.from(this.element.querySelectorAll("[data-id]")).map(el => el.dataset.id)
    fetch(this.urlValue, {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content
      },
      body: JSON.stringify({ ordered_ids: ids })
    })
  }
}
