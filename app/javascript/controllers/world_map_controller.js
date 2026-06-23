import { Controller } from "@hotwired/stimulus"

  export default class extends Controller {
    static values = { filled: Object, saveUrl: String }

    connect() {
      this.selectedCode = null
      this.applyFill()
      this.element.querySelectorAll("path[id], path[data-country]").forEach(path => {
        path.style.cursor = "pointer"
        path.addEventListener("click", this.handleClick.bind(this))
      })
      this.element.setAttribute("data-world-map-connected", "true")
    }

    applyFill() {
      Object.entries(this.filledValue).forEach(([ code, color ]) => {
        const path = this.findPath(code)
        if (path) path.style.fill = color
      })
    }

    handleClick(event) {
      const path = event.currentTarget
      const code = path.id || path.dataset.country
      if (!code) return

      this.selectedCode = code
      document.getElementById("map-panel").classList.remove("hidden")
      document.getElementById("map-panel-title").textContent = code

      const existing = this.filledValue[code]
      if (existing) document.getElementById("map-color-picker").value = existing

      document.getElementById("map-save-btn").onclick = () => this.save(code, path)
      document.getElementById("map-clear-btn").onclick = () => this.clear(code, path)
    }

    save(code, path) {
      const color = document.getElementById("map-color-picker").value
      path.style.fill = color
      this.filledValue = { ...this.filledValue, [code]: color }
      document.getElementById("map-panel").classList.add("hidden")

      const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content
      const headers = { "Content-Type": "application/json" }
      if (csrfToken) headers["X-CSRF-Token"] = csrfToken

      fetch(this.saveUrlValue, {
        method: "POST",
        headers: headers,
        body: JSON.stringify({ country_code: code, color })
      }).then(response => {
        if (response.ok) {
          window.location.reload()
        }
      })
    }

    clear(code, path) {
      path.style.fill = ""
      const updated = { ...this.filledValue }
      delete updated[code]
      this.filledValue = updated
      document.getElementById("map-panel").classList.add("hidden")

      const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content
      const headers = {}
      if (csrfToken) headers["X-CSRF-Token"] = csrfToken

      fetch(`${this.saveUrlValue}?country_code=${code}`, { 
        method: "DELETE",
        headers: headers
      }).then(response => {
        if (response.ok) {
          window.location.reload()
        }
      })
    }

    findPath(code) {
      return this.element.querySelector(`path[id="${code}"], path[data-country="${code}"]`)
    }
  }
