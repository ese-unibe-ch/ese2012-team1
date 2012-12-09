$(function () {
    'use strict';

    $('#query').autocomplete({
        serviceUrl:'/users',
        onSelect: function (user_name, data) {
            var user_id = data[0]
            var $hiddenInput = $('<input/>',{type:'hidden', name:"hidden"+user_id, value:user_id});
            var $div = $('<span/>', {id:"div"+user_id,class:'receiver'})
            var $button = $('<button/>', {type:'button', class:"remove", onclick:"removeReceiver("+ user_id +")" })
            $button.html("x")
            $div.html(user_name)
            $button.appendTo($div)
            $("input[id=query]").val('')
            $hiddenInput.appendTo('#send_form')
            $div.appendTo('#receivers')
        },
        fnFormatResult: function(value, data, currentValue) {
            var reEscape = new RegExp('(\\' + ['/', '.', '*', '+', '?', '|', '(', ')', '[', ']', '{', '}', '\\'].join('|\\') + ')', 'g');
            var pattern = '(' + currentValue.replace(reEscape, '\\$1') + ')';
            var picture = "<img src=" + data[2] + " class=\"x-small-picture\" alt=" + value + ">"
            return picture + " " + value.replace(new RegExp(pattern, 'gi'), '<strong>$1<\/strong>') + " " + data[1]
        }
    });
});