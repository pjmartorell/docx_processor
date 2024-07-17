import { Controller } from "@hotwired/stimulus";
import fileSaver from "file-saver";

export default class extends Controller {
    static targets = ["submitButton"]

    connect() {
        this.submitButton = this.submitButtonTarget;
        this.originalButtonText = this.submitButton.value;
    }

    handleSubmit(event) {
        event.preventDefault();
        this.submitButton.disabled = true;
        this.submitButton.value = "Processant...";

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
                this.submitButton.value = this.originalButtonText;
            });
    }
}
