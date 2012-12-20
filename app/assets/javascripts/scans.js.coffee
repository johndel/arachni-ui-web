# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

scan_type_selected = false

showGoButton = () ->
    url = $('#scan_url').val()
    if scan_type_selected &&
    ((url.startsWith( 'http://' ) && !url.endsWith( 'http://' )) ||
    (url.startsWith( 'https://' ) && !url.endsWith( 'https://' )))
        $('#go-btn').show( 100 )
    else
        $('#go-btn').hide( 100 )

hadleAutoDispatcherNotice = ( type ) ->
    if type == 'remote'
        if $('#dispatcher').val() == 'auto'
            $('#auto-remote-dispatcher-notice').show( 50 )
        else
            $('#auto-remote-dispatcher-notice').hide( 50 )
    else if type == 'hpg'
        if $('#master_dispatcher').val() == 'auto'
            $('#auto-master-remote-dispatcher-notice').show( 50 )
        else
            $('#auto-master-remote-dispatcher-notice').hide( 50 )

pickScanType = ( type ) ->
    $('#hpg-alert').show( 50 )

    scan_type_selected = true

    hadleAutoDispatcherNotice( type )
    showGoButton()
    switch type
        when 'direct'
            $('#scan_type').val( 'direct' )

            $('#dispatcher-hpg').hide( 50 )
            $('#dispatcher-remote').hide( 50 )
            $('#direct').show
        when 'remote'
            $('#scan_type').val( 'remote' )

            $('#direct').hide( 50 )
            $('#dispatcher-hpg').hide( 50 )
            $('#dispatcher-remote').show( 50 )
        when 'hpg'
            $('#scan_type').val( 'grid' )

            $('#direct').hide( 50 )
            $('#dispatcher-remote').hide( 50 )
            $('#dispatcher-hpg').show( 50 )

showSelectedProfile = () ->
    id = $('#scan_profile').val()
    $.ajax '/profiles/' + id + '.js',
        type: 'GET'
        dataType: 'html'
        success: ( data, textStatus, jqXHR ) ->
            $('#show-profile-container').html data
            $('#profile-edit-btn').attr( 'href', '/profiles/' + id + '/edit' )
            $('#show-profile').modal()


window.restoreAccordion = () ->
    aGroup = $.cookie( 'activeAccordionGroup' )
    if aGroup
        $( ".collapse" ).removeClass( 'in' )
        for collapsable in aGroup.split( ':' )
            if $( "#" + collapsable )
                $( "#" + collapsable ).addClass( 'in' )
    $( ".collapse" ).on 'shown', ->
        aGroup += ':' + $( this ).attr( 'id' ) + ':'
        $.cookie( 'activeAccordionGroup', aGroup )
    $( ".collapse" ).on 'hidden', ->
        aGroup = aGroup.replace( new RegExp( ':' + $( this ).attr( 'id' ) + ':', 'g' ), '' )
        $.cookie( 'activeAccordionGroup', aGroup )


jQuery ->
    $('#direct-btn').click ->
        pickScanType( 'direct' )
    $('#remote-btn').click ->
        pickScanType( 'remote' )
    $('#hpg-btn').click ->
        pickScanType( 'hpg' )
    $('#scan_url').keyup ->
        showGoButton()
    $('#scan_url').blur ->
        showGoButton()
    $('#dispatcher').change ->
        hadleAutoDispatcherNotice( 'remote' )
    $('#master_dispatcher').change ->
        hadleAutoDispatcherNotice( 'hpg' )
    $('#peek-profile').click ->
        showSelectedProfile()
    window.restoreAccordion()