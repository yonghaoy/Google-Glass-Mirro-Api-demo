<!--
Copyright (C) 2013 Google Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
-->
<%@ page import="com.google.api.client.auth.oauth2.Credential" %>
<%@ page import="com.google.api.services.mirror.model.Contact" %>
<%@ page import="com.google.glassware.MirrorClient" %>
<%@ page import="com.google.glassware.WebUtil" %>
<%@ page import="java.util.List" %>
<%@ page import="com.google.api.services.mirror.model.TimelineItem" %>
<%@ page import="com.google.api.services.mirror.model.Subscription" %>
<%@ page import="com.google.api.services.mirror.model.Attachment" %>
<%@ page import="com.google.glassware.MainServlet" %>
<%@ page import="org.apache.commons.lang3.StringEscapeUtils" %>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<!doctype html>
<%
  String userId = com.google.glassware.AuthUtil.getUserId(request);
  String appBaseUrl = WebUtil.buildUrl(request, "/");

  Credential credential = com.google.glassware.AuthUtil.getCredential(userId);

  Contact contact = MirrorClient.getContact(credential, MainServlet.CONTACT_ID);

  List<TimelineItem> timelineItems = MirrorClient.listItems(credential, 3L).getItems();


  List<Subscription> subscriptions = MirrorClient.listSubscriptions(credential).getItems();
  boolean timelineSubscriptionExists = false;
  boolean locationSubscriptionExists = false;


  if (subscriptions != null) {
    for (Subscription subscription : subscriptions) {
      if (subscription.getId().equals("timeline")) {
        timelineSubscriptionExists = true;
      }
      if (subscription.getId().equals("locations")) {
        locationSubscriptionExists = true;
      }
    }
  }

%>
<html>
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>UNC SILS GLASS Mirror API DEMO</title>
  <link href="/static/bootstrap/css/bootstrap.min.css" rel="stylesheet"
        media="screen">
  <link href="/static/bootstrap/css/bootstrap-responsive.min.css"
        rel="stylesheet" media="screen">
  <link href="/static/main.css" rel="stylesheet" media="screen">
</head>
<body>
<div class="navbar navbar-inverse navbar-fixed-top">
  <div class="navbar-inner">
    <div class="container">
      <a class="brand" href="#">It's a demo for Friday's meeting.</a>
    </div>
  </div>
</div>

<div class="container">

  <% String flash = WebUtil.getClearFlash(request);
    if (flash != null) { %>
  <div class="alert alert-info"><%= StringEscapeUtils.escapeHtml4(flash) %></div>
  <% } %>

  <h1>Your Recent Timeline</h1>
  <div class="row">

    <div style="margin-top: 5px;">

      <% if (timelineItems != null && !timelineItems.isEmpty()) {
        for (TimelineItem timelineItem : timelineItems) { %>
      <div class="span4">
        <table class="table table-bordered">
          <tbody>
            <tr>
              <th>ID</th>
              <td><%= timelineItem.getId() %></td>
            </tr>
            <tr>
              <th>Text</th>
              <td><%= StringEscapeUtils.escapeHtml4(timelineItem.getText()) %></td>
            </tr>
            <tr>
              <th>HTML</th>
              <td><%= StringEscapeUtils.escapeHtml4(timelineItem.getHtml()) %></td>
            </tr>
            <tr>
              <th>Attachments</th>
              <td>
                <%
                if (timelineItem.getAttachments() != null) {
                  for (Attachment attachment : timelineItem.getAttachments()) {
                    if (MirrorClient.getAttachmentContentType(credential, timelineItem.getId(), attachment.getId()).startsWith("")) { %>
                <img src="<%= appBaseUrl + "attachmentproxy?attachment=" +
                  attachment.getId() + "&timelineItem=" + timelineItem.getId() %>">
                <%  } else { %>
                <a href="<%= appBaseUrl + "attachmentproxy?attachment=" +
                  attachment.getId() + "&timelineItem=" + timelineItem.getId() %>">
                  Download</a>
                <%  }
                  }
                } else { %>
                <span class="muted">None</span>
                <% } %>
              </td>
            </tr>
            <tr>
              <td colspan="2">
                <form class="form-inline"
                      action="<%= WebUtil.buildUrl(request, "/main") %>"
                      method="post">
                  <input type="hidden" name="itemId"
                         value="<%= timelineItem.getId() %>">
                  <input type="hidden" name="operation"
                         value="deleteTimelineItem">
                  <button class="btn btn-block btn-danger"
                          type="submit">Delete</button>
                </form>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
      <% }
      } else { %>
      <div class="span12">
        <div class="alert alert-info">
          You haven't added any items to your timeline yet. Use the controls
          below to add something!
        </div>
      </div>
      <% } %>
    </div>
    <div style="clear:both;"></div>
  </div>

  <hr/>

  <div class="row">
    <div class="span4">
      <h2>Timeline</h2>

      <p>When you first sign in, this Glassware inserts a welcome message. Use
        these controls to insert more items into your timeline. Learn more
        about the timeline APIs
        <a href="https://developers.google.com/glass/timeline">here</a>.</p>


      <form action="<%= WebUtil.buildUrl(request, "/main") %>" method="post">
        <input type="hidden" name="operation" value="insertItem">
        <textarea class="span4" name="message">GO HEELS!</textarea><br/>
        <button class="btn btn-block" type="submit">
          insert the above message
        </button>
      </form>

      <form action="<%= WebUtil.buildUrl(request, "/main") %>" method="post">
        <input type="hidden" name="operation" value="insertItem">
        <textarea class="span4" name="html_message"></textarea><br/>
        <button class="btn btn-block" type="submit">
          insert the above html
        </button>
      </form>
      <form action="<%= WebUtil.buildUrl(request, "/main") %>" method="post">
        <input type="hidden" name="operation" value="insertItem">
        <input type="hidden" name="contenttype" value="image/jpeg">
        <input type="hidden" name="message" value="it's a test for image">
        <input type="hidden" name="imageUrl" value="<%= appBaseUrl +
               "static/images/unc.jpg" %>">
        <input type="hidden" name="contentType" value="image/jpeg">
        <button class="btn btn-block" type="submit">insert a picture
          <img class="button-icon" src="<%= appBaseUrl +
               "static/images/unc.jpg" %>">
        </button>
      </form>
      <form action="<%= WebUtil.buildUrl(request, "/main") %>" method="post">
        <input type="hidden" name="operation" value="insertPaginatedItem">
        <button class="btn btn-block" type="submit">
          insert a paginated html card</button>
      </form>
      <form action="<%= WebUtil.buildUrl(request, "/main") %>" method="post">
        <input type="hidden" name="operation" value="insertItemWithAction">
        <button class="btn btn-block" type="submit">
          insert a card you can reply to</button>
      </form>
      <hr>
      <form action="<%= WebUtil.buildUrl(request, "/main") %>" method="post">
        <input type="hidden" name="operation" value="insertIteAllUsers">
        <button class="btn btn-block" type="submit">
          insert a card to all users</button>
      </form>
    </div>

    <div class="span4">
      <h2>contacts</h2>

      <p>by default, this project inserts a single contact that accepts
        all content types. learn more about contacts
        <a href="https://developers.google.com/glass/contacts">here</a>.</p>

      <% if (contact == null) { %>
      <form action="<%= WebUtil.buildUrl(request, "/main") %>" method="post">
        <input type="hidden" name="operation" value="insertContact">
        <input type="hidden" name="iconUrl" value="<%= appBaseUrl +
               "static/images/tarheel.jpg" %>">
        <input type="hidden" name="id"
               value="<%= MainServlet.CONTACT_ID %>">
        <input type="hidden" name="name"
               value="<%= MainServlet.CONTACT_NAME %>">
        <button class="btn btn-block btn-success" type="submit">
          insert a contact
        </button>
      </form>
      <% } else { %>
      <form action="<%= WebUtil.buildUrl(request, "/main") %>" method="post">
        <input type="hidden" name="operation" value="deleteContact">
        <input type="hidden" name="id" value="<%= MainServlet.CONTACT_ID %>">
        <button class="btn btn-block btn-danger" type="submit">
          delete the contact
        </button>
      </form>
      <% } %>

      <h3>voice commands</h3>
      <p>the contact is combined to me email address "yyhao1@gmail.com", it accepts the <strong>take a
        note</strong> command. take a note with the "java quick start" contact
        and the cat in the server will record your note and reply with one of
        a few cat utterances.</p>
    </div>

    <div class="span4">
      <h2>subscriptions</h2>

      <p>by default a subscription is inserted for changes to the
        <code>timeline</code> collection. learn more about subscriptions
        <a href="https://developers.google.com/glass/subscriptions">here</a>.
      </p>

      <p class="alert alert-info">note: subscriptions require ssl. they will
        not work on localhost.</p>

      <% if (timelineSubscriptionExists) { %>
      <form action="<%= WebUtil.buildUrl(request, "/main") %>"
			  method="post">
        <input type="hidden" name="subscriptionid" value="timeline">
        <input type="hidden" name="operation" value="deleteSubscription">
        <button class="btn btn-block btn-danger" type="submit" class="delete">
          unsubscribe from timeline updates
        </button>
      </form>
      <% } else { %>
      <form action="<%= WebUtil.buildUrl(request, "/main") %>" method="post">
        <input type="hidden" name="operation" value="insertSubscription">
        <input type="hidden" name="collection" value="timeline">
        <button class="btn btn-block btn-success" type="submit">
          subscribe to timeline updates
        </button>
      </form>
      <% } %>

      <% if (locationSubscriptionExists) { %>
      <form action="<%= WebUtil.buildUrl(request, "/main") %>" 
			  method="post">
        <input type="hidden" name="subscriptionid" value="locations">
        <input type="hidden" name="operation" value="deleteSubscription">
        <button class="btn btn-block btn-danger" type="submit" class="delete">
          unsubscribe from location updates
        </button>
      </form>
      <% } else { %>
      <form action="<%= WebUtil.buildUrl(request, "/main") %>" method="post">
        <input type="hidden" name="operation" value="insertSubscription">
        <input type="hidden" name="collection" value="locations">
        <button class="btn btn-block btn-success" type="submit">
          subscribe to location updates
        </button>
      </form>
      <% } %>
    </div>
  </div>
</div>

<script
    src="//ajax.googleapis.com/ajax/libs/jquery/1.9.1/jquery.min.js"></script>
<script src="/static/bootstrap/js/bootstrap.min.js"></script>
</body>
</html>
