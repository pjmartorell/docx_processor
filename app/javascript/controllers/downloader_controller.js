import { Controller } from "@hotwired/stimulus";
import fileSaver from "file-saver";

export default class extends Controller {
    static targets = ["submitButton", "spinner", "buttonText"]

    connect() {
        this.submitButton = this.submitButtonTarget;
        this.spinner = this.spinnerTarget;
        this.originalButtonText = this.buttonTextTarget.innerHTML;
        this.buttonText = this.buttonTextTarget;
    }

    handleSubmit(event) {
        event.preventDefault();
        this.submitButton.disabled = true;
        this.buttonText.innerHTML = "Processant...";
        this.spinner.classList.remove("hidden");

        const form = event.target;
        const data = new FormData(form);

        fetch(form.action, {
            method: form.method,
            body: data,
            headers: { "Accept": "text/vnd.turbo-stream.html" },
        })
            .then(response => response.blob())
            .then(blob => {
                if (blob.type === "application/zip") {
                    fileSaver.saveAs(blob, "processed_files.zip");
                    const successMessage = `
                        <turbo-stream action="append" target="flash">
                            <template>
                                <div class="border border-green-400 bg-green-200 text-green-800 p-4 rounded mt-4 flash-message" data-flash-target="message">
                                    El processament s'ha completat correctament
                                </div>
                            </template>
                        </turbo-stream>`;
                    Turbo.renderStreamMessage(successMessage);
                } else {
                    return blob.text().then(text => {
                        if (text.startsWith("<turbo-stream")) {
                            Turbo.renderStreamMessage(text);
                        }
                    });
                }
            })
            .finally(() => {
                this.submitButton.disabled = false;
                this.buttonText.innerHTML = this.originalButtonText;
                this.spinner.classList.add("hidden");
            });
    }
}
