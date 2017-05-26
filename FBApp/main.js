// FB. something Only works after `FB.init` is called


// TODOs:
// delete post option
// jquery calendar
// weather display
access_token = '';
page_id = 0;
page_name = "";
function setUserLoggedInState() {
  $(".LoginButton").addClass('hidden');
  $(".cnct_msg").removeClass('hidden');
  $(".LogoutButton").removeClass('hidden');
  $(".disp_section").removeClass('hidden');
}

function setAccessToken() {
  if(access_token == '') {
    FB.api('/' + page_id, {fields: 'access_token'}, function(response) {
      access_token = response.access_token;
    });
  }
}

function getTargetLocation() {
  var loc =  $('.location_select select').val();

  return {
    "geo_locations": {
      "countries": [
        loc
      ]}
    }
}

function setUserLoggedOutState() {
  $(".LoginButton").removeClass('hidden');
  $(".cnct_msg").addClass('hidden');
  $(".LogoutButton").addClass('hidden');
  $(".disp_section").addClass('hidden');
}

function myFacebookLogout() {
  FB.logout(function(response) {
    setUserLoggedOutState();
  });
}

function myFacebookLogin() {
  FB.login(function(response) {
    if(response.status == 'connected') {
      setUserLoggedInState();
    }
  });
}

function initLoginStatus() {
  FB.getLoginStatus(function(response) {
    if(response.status == 'connected') {
      setUserLoggedInState();
      setAccessToken();
      getFeedList();
      // postToFeed();
      showPageInfo();
    } else {
      setUserLoggedOutState();
    }
  });
}

function showPageInfo() {
  if($(".page_info a h2").html() == "") {
    FB.api("/" + page_id, 'GET', {fields: "link,name"}, function(r) {
      $(".page_info a h2").html(r.name);
      $(".page_info a").attr('href', r.link);
    });
  }
}

function enablePostButton(clear) {
  if(clear) {
    $('.post_content').val('');
    if($('#scheduled')[0].checked) {
      $('#scheduled').trigger('click');
    }
  }
  $('#post_submit').attr('disabled', false);
}

function schedulePostToFB(message, scheduled_time, target_loc) {
  FB.api('/' + page_id + '/feed', 'post',
    {message: message, access_token: access_token, published: false,
      scheduled_publish_time: scheduled_time,
      feed_targeting: target_loc},
    function(response) {
      console.log(response);
      enablePostButton(true);
    });
}

function postToFB(message, target_loc) {
  FB.api('/' + page_id + '/feed', 'post', {message: message, access_token: access_token, feed_targeting: target_loc}, function(response) {
    console.log(response);
    enablePostButton(true);
  });
}

function post_content(e) {
  $(e).attr('disabled', true);
  message = $('.post_content').val()
  target_loc = getTargetLocation();
  if($("#scheduled")[0].checked) {
    if($("#scheduled_time input").val() != '') {
      d = new Date();
      d.setDate(d.getDate() + parseInt($("#scheduled_time_days").val()))
      d.setHours(d.getHours() + parseInt($("#scheduled_time_hours").val()))
      d.setMinutes(d.getMinutes() + parseInt($("#scheduled_time_minutes").val()))
      schedulePostToFB(message, parseInt(d.getTime()/1000, target_loc))
    } else {
      $("#scheduled_time").addClass('red_bg')
    }
  } else {
    postToFB(message, target_loc)
  }
}

function getPostImpressions(post_id) {
  FB.api('/' + post_id + '/insights/post_impressions', function(response) {
    count = 0;
    data = response.data;
    for(var i = 0; i < data.length; i++) {
      for(var j = 0; j < data[i].values.length; j++) {
        count += data[i].values[j].value;
      }
    }
    $("." + post_id + " .impressions_count").html(count);
  });
}

function getPrintableDate(d_str, notime) {
  var notime = notime || false;
  if(typeof d_str == 'string')
    var d = new Date(Date.parse(d_str));
  else
    var d = new Date(d_str * 1000);

  if(notime)
    return d.toDateString()
  else
    return d.toDateString() + " " + d.toLocaleTimeString();
}

function addFeedHTML(data, c) {
  var h = $('.sample_post').clone();
  h.removeClass('hidden');
  h.removeClass('sample_post');
  h.addClass(data.id);
  h.attr('id', 'fb_' + data.id);
  h.addClass('fb_post');
  h.find('.from').html(data.from.name);
  h.find('.created').html(getPrintableDate(data.created_time));
  h.find('.message').html(data.message);
  h.find('.deletepost').attr('id', 'delete_' + data.id);
  if(data.scheduled_publish_time) {
    h.find('.publish_time').html('Publish time: ' + getPrintableDate(data.scheduled_publish_time));
    h.find('.publish_time').removeClass('hidden');
  }
  
  $(c).append(h);
  getPostImpressions(data.id);
}

function addWeatherHTML(data, target_c) {
  console.log(data);
  var h = $(".weather_part .sample_weather_day_desc").clone();
  h.removeClass('hidden');
  h.removeClass('sample_weather_day_desc');
  h.addClass('weather_day_desc')
  skycons.add(h.find('.icon')[0], data.icon);
  h.find('.date').html(getPrintableDate(data.time, true));
  h.find('.summary').html(data.summary);
  h.find('.min_temp').html("Min: " + data.temperatureMin + " &#8451;");
  h.find('.max_temp').html("Max: " + data.temperatureMax + " &#8451;");

  $(target_c).append(h);
  // TODO sunrise sunset times
}

function setWeatherDetails() {
  if($(".weather_part .content .today").html() == '') {
    console.log('getting weather details');
    $.getJSON(
      'https://api.darksky.net/forecast/b6085250354a89d9e053d786dcb4ff2f/37.8267,-122.4233?exclude=minutely,hourly,flags,currently&units=si&callback=?',
      function(response) {
        window.x = response;
        var data = response.daily.data;
        addWeatherHTML(data[0], ".weather_part .content .today");
  
        for(var i = 1; i < 4; i++) {
          addWeatherHTML(data[i], ".weather_part .content .other");
        }
      })
  }
}

function confirmDeletePost(post_id) {
  var dialog = $('.delete_confirm');
  dialog.find('.confirm').attr('id', post_id);

  dialog.find('.FB_post_message').html($('#fb_' + post_id + " .message").html());
  dialog[0].showModal();
}

function deletePostFB(e) {
  var post_id = $(e).attr('id');
  $('.delete_confirm .confirm').attr('disabled', true);
  FB.api('/' + post_id, 'DELETE', {access_token: access_token}, function(response) {
    console.log(response);
    removePostHTML(post_id);
    closeDialog();
  });
}

function removePostHTML(post_id) {
  $('#fb_' + post_id).remove();
}

function deletePost(e) {
  var post_id = $(e).attr('id').split('delete_')[1];

  if(post_id != '') {
    confirmDeletePost(post_id);
  }
}

function postToFeed() {
  showDispPart('.post_to_feed');
  setupIngsTasks();
  setWeatherDetails();
}

function getFeedList() {
  showDispPart('.released_posts');
  $('.released_posts .published_posts .content').html('');
  $('.released_posts .unpublished_posts .content').html('');
  FB.api('/' + page_id + '/feed', {fields: 'id,message,from,to,is_published,created_time'}, function(response) {
    data = response.data
    for(var i = 0; i < data.length; i++) {
      addFeedHTML(data[i], '.released_posts .published_posts .content');
    }
  });
  FB.api('/' + page_id + '/promotable_posts', {fields: 'id,message,from,to,is_published,created_time,scheduled_publish_time', is_published: false}, function(response) {
    var data = response.data
    for(var i = 0; i < data.length; i++) {
      addFeedHTML(data[i], '.released_posts .unpublished_posts .content');
    }
  });
}

function showDispPart(c) {
  $(".disp_section_part").addClass('hidden');
  $(c).removeClass('hidden');
}

$(document).ready(function() {
  $("#scheduled").on('click', function() {
    if($("#scheduled")[0].checked) {
      $('#scheduled_time').removeClass('hidden');
    } else {
      $('#scheduled_time').addClass('hidden');
    }
  })

  $(".builder_helper").on('click', '.item', function(e) {
    
    var append_txt = $(e.target).html();
    if($('.post_content').val() != "")
      append_txt = "\n" + append_txt;
    $('.post_content').append(append_txt);
  })
});

function closeDialog() {
  $('.delete_confirm')[0].close();
}

var recipe_ing = [{'name': 'Tomatos'}, {'name': 'Onions'}, {'name': 'Spinach'}]
var recipe_task = [{'name': 'Bake'}, {'name': 'Fry'}]

function setupIngsTasks() {
  if($(".builder_helper .ingredients").html() == "") {
    for(var i = 0; i < recipe_ing.length; i++) {
      $(".builder_helper .ingredients").append("<span class='item'>" + recipe_ing[i].name + "</span>")
    }
  }
  if($(".builder_helper .tasks").html() == "") {
    for(var i = 0; i < recipe_task.length; i++) {
      $(".builder_helper .tasks").append("<span class='item'>" + recipe_task[i].name + "</span>")
    }
  }
}
