function removeReceiver($user_id) {
    $("#hidden" + $user_id).remove()
    $("#div" + $user_id).remove()
}