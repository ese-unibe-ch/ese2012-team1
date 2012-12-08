$(function () {
    'use strict';

    $('#query').autocomplete({
        serviceUrl:'/users',
        onSelect: function (user_name, user_id) {
            var $hiddenInput = $('<input/>',{type:'hidden', name:"hidden"+user_id, value:user_id});
            var $div = $('<span/>', {id:"div"+user_id,class:'receiver'})
            var $button = $('<button/>', {type:'button', class:"remove", onclick:"removeReceiver("+ user_id +")" })
            $button.html("x")
            $div.html(user_name)
            $button.appendTo($div)
            $("input[id=query]").val('')
            $hiddenInput.appendTo('#send_form')
            $div.appendTo('#receivers')
        }
    });
});