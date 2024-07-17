import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
    static targets = ["message"]

    connect() {
        this.fadeOutMessages();
    }

    messageTargetConnected(target) {
        this.fadeOutMessage(target);
    }

    fadeOutMessages() {
        this.messageTargets.forEach((message) => this.fadeOutMessage(message));
    }

    fadeOutMessage(message) {
        setTimeout(() => {
            message.style.transition = "opacity 1s ease-out";
            message.style.opacity = "0";
            setTimeout(() => {
                message.remove();
            }, 1000); // Matches the CSS transition duration
        }, 3000); //
    }
}
