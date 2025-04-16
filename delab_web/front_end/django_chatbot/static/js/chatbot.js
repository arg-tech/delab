document.getElementById('postButton').addEventListener('click', async function () {
    const userInput = document.getElementById('user_input').value;
    if (!userInput.trim()) return; // Verhindert leere Nachrichten

    const chatBox = document.getElementById('chatBox');
    const loadingDots = document.getElementById('loadingDots');

    // Nutzer-Nachricht erstellen
    const userMessage = document.createElement('div');
    userMessage.classList.add('chat-message');
    userMessage.innerHTML = `
                <img src="${STATIC_PATHS.profileYou}" alt="profile_user0.png">
                <div class="chat-text">
                    <strong>You</strong>${userInput}
                </div>
            `;
    chatBox.appendChild(userMessage);
    document.getElementById('user_input').value = ""; // Eingabe leeren

    // Ladeanimation aktivieren
    loadingDots.style.display = "block";

    const csrfToken = document.querySelector('input[name="csrfmiddlewaretoken"]').value;

    const response = await fetch("/ask/", {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
            'X-CSRFToken': csrfToken
        },
        body: `user_input=${encodeURIComponent(userInput)}`
    });

    const data = await response.json();

    // Ladeanimation verstecken
    loadingDots.style.display = "none";
    let botText = "Oops! Something went wrong!";
    let showAnalytics = false;

    if (data.answer && data.answer.df && data.answer.df.length > 0) {
        botText = data.answer.df[0].out_llm;
        showAnalytics = true;
    }

    const interventionProb = data.answer.intervention_probability[0];
    if (interventionProb > 0.5) {
        const botMessage = document.createElement('div');
        botMessage.classList.add('chat-message');
        botMessage.innerHTML = `
                    <img src="${STATIC_PATHS.profileBot}" alt="profile_user0.png">
                    <div class="chat-text">
                        <strong>Chatbot</strong>${botText}
                    </div>
                `;
        chatBox.appendChild(botMessage);
    }
    if (showAnalytics) {
        document.getElementById("chatExtras").style.display = "block";
        const analyticsList = document.getElementById("analyticsList");
        analyticsList.innerHTML = ""; // Vorherigen Inhalt löschen

        let interventionLabel = document.getElementById("interventionLabel");
        if (!interventionLabel) {
            interventionLabel = document.createElement("p");
            interventionLabel.id = "interventionLabel";
            const analyticsBox = document.getElementById("analyticsPanel");
            analyticsBox.insertBefore(interventionLabel, analyticsBox.querySelector("ul"));
        }

        interventionLabel.style.fontWeight = "bold";
        interventionLabel.style.color = interventionProb > 0.5 ? "red" : "green";
        interventionLabel.innerText = interventionProb > 0.5 ? "Intervention needed!" : "No Intervention needed.";

        const analyticsPanelHeader = document.getElementById("analyticsPanelHeader");


        const hateSpeechDetected = data.answer.hate_speech_detected[0];
        if (hateSpeechDetected) {
            analyticsPanelHeader.innerText = "Hate speech detected.";
        }
        else {
            analyticsPanelHeader.innerText = "Five Most Relevant Features:";

            const featureValues = data.answer.features[0];
            const featureImportance = data.answer.feature_importance[0];

            const featureNameMap = {
                "sent_positive": "Positive sentiment (user comment)",
                "sent_neutral": "Neutral sentiment (user comment)",
                "sent_negative": "Negative sentiment (user comment)",
                "2_sent_negative": "Negative sentiment (input comment)",
                "2_sent_neutral": "Neutral sentiment (input comment)",
                "2_sent_positive": "Positive sentiment (input comment)",
                "sent_negative_dev": "Sentiment gap between comments (negative)",
                "sent_neutral_dev": "Sentiment gap between comments (neutral)",
                "sent_positive_dev": "Sentiment gap between comments (positive)",
                "argpred_0": "Justification (user comment)",
                "argpred_1": "Justification (user comment)",
                "2_argpred_0": "Justification (input comment)",
                "2_argpred_1": "Justification (input comment)",
                "argpred_0_dev": "Justification between comments",
                "argpred_1_dev": "Justification between comments",
                "discourse_markers_count": "Discourse markers (user comment)",
                "epistemic_markers_count": "Epistemic markers (user comment)",
                "lexical_reachness": "Lexical richness (user comment)",
                "dependency_depth": "Syntactic complexity (user comment)",
                "dependency_score": "Syntactic complexity (user comment)",
                "self_contradiction": "Self contradiction (between user comments)",
                "2_discourse_markers_count": "Discourse markers (input comment)",
                "2_epistemic_markers_count": "Epistemic markers (input comment)",
                "2_lexical_reachness": "Lexical richness (input comment)",
                "2_dependency_depth": "Syntactic complexity (input comment)",
                "2_dependency_score": "Syntactic complexity (input comment)",
                "2_self_contradiction": "Self contradiction (input comment)",
                "cosine_prev": "Lexical similarity between comments",
                "no_relation": "Argument relations (none)",
                "inference": "Argument relations (support between comments)",
                "conflict": "Argument relations (attack between comments)",
                "rephrase": "Argument relations (rephrase between comments)"
            };

            const importanceArray = Object.entries(featureImportance)
                .filter(([key]) => key !== '_row')
                .map(([key, value]) => ({ key, value }));

            const topFeatures = importanceArray
                .sort((a, b) => Math.abs(b.value) - Math.abs(a.value))
                .slice(0, 5);


            topFeatures.forEach(({ key, value }) => {
                const actualValue = featureValues[key] !== undefined ? featureValues[key] : "N/A";
                const displayName = featureNameMap[key] || key;

                const item = document.createElement("li");
                item.innerHTML = `<strong>${displayName}</strong>: ${actualValue}`;
                analyticsList.appendChild(item);
            });
        }

        const trafficLightImg = document.getElementById("trafficLightImg");

        // Bildpfad festlegen je nach Wahrscheinlichkeit
        let imgFullPath = "";

        if (hateSpeechDetected) {
            imgFullPath = STATIC_PATHS.red;
        } else if (interventionProb > 0.5) {
            imgFullPath = STATIC_PATHS.red;
        } else if (interventionProb > 0.4) {
            imgFullPath = STATIC_PATHS.yellow;
        } else {
            imgFullPath = STATIC_PATHS.green;
        }

        trafficLightImg.src = imgFullPath;
    }
    
    // Automatisches Scrollen zum neuesten Beitrag
    chatBox.scrollTop = chatBox.scrollHeight;
});

document.getElementById("jsonUploadForm").addEventListener("submit", async function(event) {
    event.preventDefault(); // Standardformularverhalten verhindern

    const formData = new FormData();
    const jsonFile = document.getElementById("jsonFile").files[0];

    if (!jsonFile) {
        alert("Bitte eine JSON-Datei auswählen.");
        return;
    }

    formData.append("jsonFile", jsonFile);

    const csrfToken = document.querySelector('[name=csrfmiddlewaretoken]').value;

    try {
        const response = await fetch("/upload_json/", {
            method: "POST",
            headers: {
                "X-CSRFToken": csrfToken
            },
            body: formData
        });

        const result = await response.json();
        document.getElementById("uploadStatus").innerText = result.message;

        // Wenn Upload erfolgreich (du kannst hier auch auf result.success prüfen, falls vorhanden)
        if (response.ok) {
            setTimeout(() => {
                location.reload();
            }); // kurze Verzögerung, damit Nachricht sichtbar bleibt
        }
    } catch (error) {
        console.error("Fehler beim Hochladen:", error);
        document.getElementById("uploadStatus").innerText = "Fehler beim Hochladen!";
    }
});