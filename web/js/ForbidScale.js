(function () {
  'use strict';
  var deviceIsWindowsPhone = navigator.userAgent.indexOf("Windows Phone") > -1;
  var deviceIsSafari = /Safari/.test(navigator.userAgent) && !deviceIsWindowsPhone;
  function ForbidScale(layer, options) {
    if (deviceIsSafari) {
      var that = this;
      that.lastTouchTime = 0;
      that.lastTouchIdentifier = 0;
      that.targetElement = null;
      that.tapDelay = options ? options.tapDelay ? options.tapDelay : 200 : 200;
      layer.addEventListener(
        'touchstart',
        function (event) {
          var touch;
          touch = event.targetTouches[0];
          that.targetElement = that.getTargetElementFromEventTarget(event.target);
          if (touch.identifier && touch.identifier === that.lastTouchIdentifier) {
            event.cancelable && event.preventDefault();
            return false
          }
          that.lastTouchIdentifier = touch.identifier;
          if (event.timeStamp - that.lastTouchTime < that.tapDelay) {
            event.cancelable && event.preventDefault();
          }
        },
        false
      );
      layer.addEventListener(
        'touchend',
        function (event) {
          that.lastTouchTime = event.timeStamp;
          if (that.needsFocus(that.targetElement)) {
            that.focus(that.targetElement);
            that.sendClick(that.targetElement, event);
            if (!that.needsClick(that.targetElement)) {
              event.preventDefault();
              that.sendClick(that.targetElement, event);
            }
          }

        },
        false
      );
    }
  }
  ForbidScale.prototype.needsClick = function (target) {
    switch (target.nodeName.toLowerCase()) {
      case "button":
      case "select":
      case "textarea":
        if (target.disabled) {
          return true
        }
        break;
      case "input":
        if ((deviceIsSafari && target.type === "file") || target.disabled) {
          return true
        }
        break;
      case "label":
      case "iframe":
      case "video":
        return true
    }
    return (/\bneedsclick\b/).test(target.className)
  };
  ForbidScale.prototype.getTargetElementFromEventTarget = function (eventTarget) {
    if (eventTarget.nodeType === Node.TEXT_NODE) {
      return eventTarget.parentNode
    }
    return eventTarget
  };
  ForbidScale.prototype.needsFocus = function (target) {
    switch (target.nodeName.toLowerCase()) {
      case "textarea":
        return true;
      case "select":
        return !deviceIsAndroid;
      case "input":
        switch (target.type) {
          case "button":
          case "checkbox":
          case "file":
          case "image":
          case "radio":
          case "submit":
            return false
        }
        return !target.disabled && !target.readOnly;
      default:
        return (/\bneedsfocus\b/).test(target.className)
    }
  };
  ForbidScale.prototype.focus = function (targetElement) {
    var length;
    if (deviceIsSafari && targetElement.setSelectionRange && targetElement.type.indexOf("date") !== 0 && targetElement
      .type !== "time" && targetElement.type !== "month" && targetElement.type !== "email") {
      length = targetElement.value.length;
      targetElement.setSelectionRange(length, length)
    } else {
      targetElement.focus()
    }
  };
  ForbidScale.prototype.sendClick = function (targetElement, event) {
    var clickEvent, touch;
    if (document.activeElement && document.activeElement !== targetElement) {
      document.activeElement.blur();
    }
    touch = event.changedTouches[0];
    clickEvent = document.createEvent("MouseEvents");
    clickEvent.initMouseEvent('click', true, true, window, 1, touch.screenX, touch.screenY,
      touch.clientX, touch.clientY, false, false, false, false, 0, null);
    clickEvent.forwardedTouchEvent = true;
    targetElement.dispatchEvent(clickEvent);
  };
  ForbidScale.attach = function (layer, options) {
    return new ForbidScale(layer, options);
  };
  if (typeof define === "function" && typeof define.amd === "object" && define.amd) {
    define(function () {
      return ForbidScale;
    })
  } else {
    if (typeof module !== "undefined" && module.exports) {
      module.exports = ForbidScale.attach;
      module.exports.ForbidScale = ForbidScale;
    } else {
      window.ForbidScale = ForbidScale;
    }
  }
})();