/**
 * Dieser Code stammt von http://www.baldenhofer.eu/blog/guggat_emol/loesungsvorschlag-um-
 * eingabefelder-waehrend-der-eingabe-mit-javascript-zu-ueberpruefen
 */

/**
 * Schreibt den Event onkeyup in das Input-Feld.
 */
function initialize(){
    var inputField = document.getElementById("password");
    inputField.setAttribute("onkeyup","inputCheck();");
}

/**
 * Die Funktion welche die Prüfung der Zahlen durchführt und passende Meldungen
 * in den Paragraphen mit der id="message" schreibt.
 */
function inputCheck(){
    var eingabe = document.getElementById("password").value;
    var messageField = document.getElementById("message");

    if (eingabe.match(/[^a-zA-Z1-9]/)) {
        messageField.innerHTML = "No special characters are allowed"
    } else if(eingabe.length < 6) {
        setTextAndColor(messageField, "Weak password. Too short", "red");
    } else if (eingabe.match(/^[A-Z]+$/)) {
        setTextAndColor(messageField, "Weak password. Only capitalized letters", "red");
    } else if (eingabe.match(/^[a-z]+$/)) {
        setTextAndColor(messageField, "Weak password. Only small letters", "red");
    } else if (eingabe.match(/^\d+$/)) {
        setTextAndColor(messageField, "Weak password. Only digits", "red");
    } else if (eingabe.match(/^([a-zA-Z])+$/) || eingabe.match(/^([a-z]|\d)+$/)
                    || eingabe.match(/^([A-Z]|\d)+$/) )  {
        setTextAndColor(messageField, "Normal Password", "orange");
    } else {
        setTextAndColor(messageField, "Gracious password! You are now allowed to enter", "green");
    }
}

function setTextAndColor(messageField, text, color) {
    messageField.innerHTML = text;
    messageField.style.color = color;
}
