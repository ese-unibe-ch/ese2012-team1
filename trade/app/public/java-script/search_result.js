
function searchViewAll() {
    document.getElementById("search_all").className = "selected";
    document.getElementById("search_item").className = "";
    document.getElementById("search_user").className = "";
    document.getElementById("search_org").className = "";

    document.getElementById("search-list-item").style.display = "block";
    document.getElementById("search-list-user").style.display = "block";
    document.getElementById("search-list-organisation").style.display = "block";

}

function searchViewItem() {
    document.getElementById("search_all").className = "";
    document.getElementById("search_item").className = "selected";
    document.getElementById("search_user").className = "";
    document.getElementById("search_org").className = "";

    document.getElementById("search-list-item").style.display = "block";
    document.getElementById("search-list-user").style.display = "none";
    document.getElementById("search-list-organisation").style.display = "none";
}

function searchViewUser() {
    document.getElementById("search_all").className = "";
    document.getElementById("search_item").className = "";
    document.getElementById("search_user").className = "selected";
    document.getElementById("search_org").className = "";

    document.getElementById("search-list-item").style.display = "none";
    document.getElementById("search-list-user").style.display = "block";
    document.getElementById("search-list-organisation").style.display = "none";
}

function searchViewOrg() {
    document.getElementById("search_all").className = "";
    document.getElementById("search_item").className = "";
    document.getElementById("search_user").className = "";
    document.getElementById("search_org").className = "selected";

    document.getElementById("search-list-item").style.display = "none";
    document.getElementById("search-list-user").style.display = "none";
    document.getElementById("search-list-organisation").style.display = "block";
}
