/**
 * Dieser Code stammt von http://www.baldenhofer.eu/blog/guggat_emol/loesungsvorschlag-um-
 * eingabefelder-waehrend-der-eingabe-mit-javascript-zu-ueberpruefen
 */

var strong = false; /*Should be true if password in password field is strong*/
var same_password = false; /*Should be true if both passwords are the same*/

/**
 * Schreibt den Event onkeyup in das Input-Feld.
 */
function initialize(){
    var inputField = document.getElementById("password");
    inputField.setAttribute("onkeyup","inputCheck();");

    var re_inputField = document.getElementById("re_password");
    re_inputField.setAttribute("onkeyup","re_inputCheck();");
}

/**
 * Die Funktion welche die Prüfung der Zahlen durchführt und passende Meldungen
 * in den Paragraphen mit der id="message" schreibt.
 */
function inputCheck(){
    var eingabe = document.getElementById("password").value;
    var messageField = document.getElementById("message");

    if (eingabe.match(/[^a-zA-Z1-9]/)) {
        messageField.innerHTML = "No special characters are allowed";
        strong = false
    } else if(eingabe.length < 6) {
        setTextAndColor(messageField, "Weak password. Too short", "red");
        strong = false
    } else if (eingabe.match(/^[A-Z]+$/)) {
        setTextAndColor(messageField, "Weak password. Only capitalized letters", "red");
        strong = false
    } else if (eingabe.match(/^[a-z]+$/)) {
        setTextAndColor(messageField, "Weak password. Only small letters", "red");
        strong = false
    } else if (eingabe.match(/^\d+$/)) {
        setTextAndColor(messageField, "Weak password. Only digits", "red");
        strong = false
    } else if (eingabe.match(/^([a-zA-Z])+$/) || eingabe.match(/^([a-z]|\d)+$/)
        || eingabe.match(/^([A-Z]|\d)+$/) )  {
        setTextAndColor(messageField, "Password must have lowercase, uppercase and digits", "red");
        strong = false
    } else {
        setTextAndColor(messageField, "Gracious password! You are now allowed to enter", "green");
        strong = true;
    }

    setButtonState()
}

function re_inputCheck(){
    var eingabe = document.getElementById("password").value;
    var re_eingabe = document.getElementById("re_password").value;
    var re_messageField = document.getElementById("re_message");

    if (eingabe == re_eingabe) {
        setTextAndColor(re_messageField, "OK, both fields ar identically.", "green");
        same_password = true
    } else {
        setTextAndColor(re_messageField, "Please retype your password.", "red");
        same_password = false
    }

    setButtonState()
}

function setTextAndColor(messageField, text, color) {
    messageField.innerHTML = text;
    messageField.style.color = color;
}

/**
 * Sets button state depending on the variables strong and same_password
 */

function setButtonState() {
    var button = document.getElementById('register').disabled;
    if (strong == true && same_password == true) {
        button.disabled = false;
    }
    else {
        button.disabled = true;
    }
}