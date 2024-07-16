import { Controller } from "@hotwired/stimulus";
import fileSaver from "file-saver";

export default class extends Controller {
    static targets = ["submitButton"];

    submit(event) {
        event.preventDefault(); // Prevent default form submission
        const form = event.target;

        // Disable button and change text
        this.submitButtonTarget.disabled = true;
        this.submitButtonTarget.value = "Submitting...";

        // Use Fetch API to submit the form
        fetch(form.action, {
            method: form.method,
            body: new FormData(form),
            headers: {
                "X-Requested-With": "XMLHttpRequest" // Optional, if needed
            }
        })
            .then(response => {
                if (response.ok) {
                    return response.blob(); // Get the response as a blob
                }
                return response.json().then(errorData => {
                    // Handle validation errors
                    this.showFlashMessages(errorData.errors);
                    throw new Error("Validation errors occurred.");
                });
            })
            .then(blob => {
                // Use FileSaver to save the zip file
                fileSaver.saveAs(blob, "processed_files.zip");
                // Re-enable the button and reset text
                this.submitButtonTarget.disabled = false;
                this.submitButtonTarget.value = "Processar"; // Reset to original text
            })
            .catch(error => {
                console.error('Error:', error);
                // Re-enable the button and reset text in case of error
                this.submitButtonTarget.disabled = false;
                this.submitButtonTarget.value = "Processar"; // Reset to original text
            });
    }

    showFlashMessages(messages) {
        // Create a flash message element
        const flashContainer = document.createElement('div');
        flashContainer.classList.add('flash-messages');

        messages.forEach(message => {
            const messageElement = document.createElement('div');
            messageElement.classList.add('alert', 'alert-danger'); // Adjust classes as needed
            messageElement.textContent = message;
            flashContainer.appendChild(messageElement);
        });

        document.body.appendChild(flashContainer); // Append to body or a specific container
        setTimeout(() => flashContainer.remove(), 5000); // Auto-remove after 5 seconds
    }
}
