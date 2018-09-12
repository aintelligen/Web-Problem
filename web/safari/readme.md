## safari H5页面双击放大问题  
**bug描述**
场景描述：H5页面，`header`中已经设置`<meta name="viewport" content="width=device-width,initial-scale=1.0,minimum-scale=1.0,maximum-scale=1.0, user-scalable=no">`，在safari中双击元素页面会自动放大    
**个人理解**  
* 标签的默认事件 ，一下两种情况页面不会放大  
    1：a标签打开页面  
    2：form表单内submit按钮（input）提交表单；button(手机中form标签里的button默认是提交表单)    
* 其他标签 `div span i li` 等等,双击标签会自动放大  

分析原因：由于a标签和提交表单按钮  相当于打开页面，把默认事件禁止了  

**解决思路**
* 阻止默认事件：`event.preventDefault()`  
* 派发事件：click  
* 特殊元素：focus

**解决方案**  
* 使用FastClick：[FastClick 原理解析](https://blog.csdn.net/handsomexiaominge/article/details/80545902) ；[具体用法](https://github.com/ftlabs/fastclick/blob/master/README.md)
* 针对safari, 参考FastClick，（个人愚见）
```javascript
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
          if (!that.needsFocus(that.targetElement)) {
            if (touch.identifier && touch.identifier === that.lastTouchIdentifier) {
              event.cancelable && event.preventDefault();
              return false
            }
            that.lastTouchIdentifier = touch.identifier;
            if (event.timeStamp - that.lastTouchTime < that.tapDelay) {
              event.cancelable && event.preventDefault();
            }
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
          } else {
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
```

**使用方法**
```javascript
if ('addEventListener' in document) {
	document.addEventListener('DOMContentLoaded', function() {
		ForbidScale.attach(document.body);
	}, false);
}
```








