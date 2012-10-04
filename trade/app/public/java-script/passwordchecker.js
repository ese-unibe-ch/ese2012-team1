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

    if(eingabe == ""){
        messageField.innerHTML = "Weak password";
    } else {
        messageField.innerHTML = "This is a really strong password!"
    }
}

