import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static values = { url: String }

  connect() {
    this.draggedItem = null;
    this.bindTouchEvents();
  }

  // --- NATIVE MOUSE DRAG EVENTS (Desktop) ---

  dragstart(event) {
    this.draggedItem = event.currentTarget;
    event.dataTransfer.effectAllowed = "move";
    event.currentTarget.classList.add("opacity-50");
  }

  dragend(event) {
    event.currentTarget.classList.remove("opacity-50");
    this.save();
  }

  dragover(event) {
    event.preventDefault();
    const target = event.currentTarget;
    if (target === this.draggedItem) return;

    const rect = target.getBoundingClientRect();
    const after = event.clientY > rect.top + rect.height / 2;
    target.parentNode.insertBefore(this.draggedItem, after ? target.nextSibling : target);
  }

  drop(event) {
    event.preventDefault();
  }

  // --- MOBILE TOUCH EVENTS (iOS / Android) ---

  bindTouchEvents() {
    // Register touch events with passive: false to allow scroll prevention
    this.element.querySelectorAll("[data-id]").forEach(item => {
      item.addEventListener("touchstart", this.handleTouchStart.bind(this), { passive: true });
      item.addEventListener("touchmove", this.handleTouchMove.bind(this), { passive: false });
      item.addEventListener("touchend", this.handleTouchEnd.bind(this), { passive: true });
    });
  }

  handleTouchStart(event) {
    this.draggedItem = event.currentTarget;
    event.currentTarget.classList.add("opacity-50");
  }

  handleTouchMove(event) {
    if (!this.draggedItem) return;
    event.preventDefault(); // Lock page scroll while dragging

    const touch = event.touches[0];
    // Find what element is currently under the user's finger coordinates
    const target = document.elementFromPoint(touch.clientX, touch.clientY)?.closest("[data-id]");

    if (target && target !== this.draggedItem && target.parentNode === this.draggedItem.parentNode) {
      const rect = target.getBoundingClientRect();
      const after = touch.clientY > rect.top + rect.height / 2;
      target.parentNode.insertBefore(this.draggedItem, after ? target.nextSibling : target);
    }
  }

  handleTouchEnd(event) {
    if (this.draggedItem) {
      this.draggedItem.classList.remove("opacity-50");
      this.draggedItem = null;
      this.save();
    }
  }

  // --- DATABASE SYNC ---

  save() {
    const items = Array.from(this.element.querySelectorAll("[data-id]"));
    const ids = items.map(el => el.dataset.id);

    // Update position numbers dynamically in the browser
    items.forEach((item, index) => {
      const badge = item.querySelector(".position-badge");
      if (badge) badge.textContent = `${index + 1}.`;
    });

    fetch(this.urlValue, {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content
      },
      body: JSON.stringify({ ordered_ids: ids })
    });
  }
}
