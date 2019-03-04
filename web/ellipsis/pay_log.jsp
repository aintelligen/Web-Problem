<%@ page contentType="text/html;charset=UTF-8" language="java"%>
<%@ taglib uri="/gcp" prefix="gcp"%>
<%@ taglib uri="/platform" prefix="platform"%>
<%@ taglib prefix="s" uri="/struts-tags"%>
<%@ taglib uri="/platform" prefix="p"%>
<%@ page import="boda.common.DB"%>
<%@ page import="boda.utility.Date2"%>
<%@ page import="boda.utility.Lang2"%>
<%@ page import="java.util.ResourceBundle"%>
<%@ page import="boda.gcp.common.GCPConstant"%>
<%@ page import="boda.platform.common.AppData"%>
<%@ page import="org.apache.commons.lang3.StringUtils" %>

<jsp:useBean id="Login" class="boda.platform.common.Login" scope="session" />
<%
	ResourceBundle rb = Lang2.getResourceBundle(session);//获得读取资源文件的对象
	String langStr = Login.getLang();
	String[][] bankList = null;
	String hover=AppData.get("A_SYSTEM_M_OVER_COLOR");
	//取得当前时间和查询起始时间和结束时间

	String sStartDate   = request.getParameter("startDate");
	String sEndDate     = request.getParameter("endDate");

	if(sEndDate == null || sEndDate.equals("")){
		sEndDate =Date2.getDateTime("yyyy-MM-dd HH:mm:ss");
	}
	if(sStartDate == null || sStartDate.equals("")){
		sStartDate = Date2.addHour(sEndDate,-4,"yyyy-MM-dd HH:mm:ss");
	}

	String orderNo = request.getParameter("order_no");
	String userID = request.getParameter("user_id");
	String payName = request.getParameter("pay_name");
	String logType = request.getParameter("log_type");
	String reqStatus = request.getParameter("req_status");

	if(orderNo == null){
		orderNo = "";
	}
	if(userID==null){
		userID = "";
	}
	if(payName==null){
		payName = "";
	}

	if(logType==null){
		logType = "";
	}
	if(reqStatus==null){
		reqStatus = "";
	}


	//分页

	int totalCount = 0;
	String sCurPage = request.getParameter("curPage");//当前页
	int iCurPage = (sCurPage == null ? 1 : Integer.parseInt(sCurPage));
	String sPageCount = request.getParameter("pageCount");
	if(sPageCount==null || "".equals(sPageCount)){
		sPageCount = "20";
	}
	int iPageCount = Integer.parseInt(sPageCount, 10);


	final int ORDER_NO = 0;
	final int USER_ID = 1;
	final int TRADE_AMT = 2;
	final int PAY_NAME = 3;
	final int CHANNEL_NAME = 4;
	final int LOG_TYPE = 5;
	final int REQ_PARAM = 6;
	final int RESP_PARAM = 7;
	final int ERROR_DETAILED = 8;
	final int REQ_STATUS = 9;
	final int LOG_DATE = 10;

	//数据库连接
	String sql = "";
	String sqlParams = "1";

	DB db = null;
	try {
		db = new DB(Login.getDSKey());
		sql = "SELECT ORDER_NO,USER_ID,TRADE_AMT,PAY_NAME,CHANNEL_NAME,LOG_TYPE,REQ_PARAM,RESP_PARAM,ERROR_DETAILED,REQ_STATUS,LOG_DATE FROM T_A_PAY_LOGGER WHERE 1=?";
		if(!"".equals(orderNo)){
			sql += " and ORDER_NO = ? ";
			sqlParams += ","+orderNo;
		}
		if(!"".equals(userID)){
			sql += " and USER_ID = ? ";
			sqlParams += ","+userID;
		}
		if(!"".equals(payName)){
			sql += " and PAY_NAME =? ";
			sqlParams += ","+payName;
		}

		if(!"".equals(logType) && !"-1".equals(logType)){
			sql += " and LOG_TYPE = ? ";
			sqlParams += ","+logType;
		}
		if(!"".equals(reqStatus) && !"-1".equals(reqStatus)){
			sql += " and REQ_STATUS = ? ";
			sqlParams += ","+reqStatus;
		}

		sql += " and  to_char(LOG_DATE,'YYYY-MM-DD HH24:MI:SS AM') between ? and ? order by LOG_DATE desc ";
		sqlParams += ","+sStartDate+","+sEndDate;

		String[] params = sqlParams.split(",");

		totalCount = Integer.parseInt(db.getQueryValue("select count(1) from (" + sql + ") t11", params));

		 int iTotalPage = (int)Math.ceil((totalCount + iPageCount - 1) / iPageCount);
	    iCurPage = (iCurPage > iTotalPage) ? 1 : iCurPage;

	    int start = (iCurPage - 1) * iPageCount + 1;
	    int end = start + iPageCount - 1;

	    String realsql = "select * from (select t10.*, rownum rn from "
	    + " ( " + sql + " ) t10 "
	    + " where rownum <= ?) where rn >= ?";

	    sqlParams += ","+end+","+start;
		params = sqlParams.split(",");  //更新参数数组
	   if (totalCount > 0) {
		   bankList = db.getQueryList(realsql, params);
	   }

	} catch (Exception e) {
		e.printStackTrace();
		request.setAttribute("error", e.getMessage());
		request.getRequestDispatcher("../public/error."+GCPConstant.PAGE_SUFFIX).forward(
				request, response);
	} finally {
		if (db != null)
			db.close();
	}

%>

<!DOCTYPE html>
<html>

<head>
	<title>
		<s:text name="70BCL.001" />
	</title>
	<meta http-equiv="Content-Language" content="zh-cn">
	<link href="../css/adm.css" rel="stylesheet" type="text/css" />
	<style>
		.copy_td_web {
			word-break: break-all;
			position: relative;
		}

		.box_json_web {
			height: 85px;
			overflow: hidden;
			display: flex;
			justify-content: center;
			align-items: center;
		}
		.texterat_hide{
			position: fixed;
			z-index:-10;
			top:-10000px;
			left:-10000px;
		}

		.opacy_div_web {
			position: absolute;
			top: 0;
			left: 0;
			z-index: 10000;
			width: 99.9%;
			height: 99.9%;
			background: rgba(0, 0, 0, 0.3);
			font-size: 14px;
			display: none;
			justify-content: center;
			align-items: center;
		}

		.opacy_div_web span {
			background: #ddd;
			display: inline-block;
			padding: 2px 10px;
			border-radius: 5px;
			cursor: pointer;
		}
		.pre_none{
			display: none;
		}

		.hover_display_web .opacy_div_web {
			display: flex;
		}
	</style>
	<script type="text/javascript" language="JavaScript" src="../js/lang_<%=langStr%>.js"></script>
	<script type="text/javascript" language="JavaScript" src="../js/forbid.js"></script>
	<script type="text/javascript" language="JavaScript" src="../js/normal.js"></script>
	<script type="text/javascript" language="JavaScript" src="../js/page.js"></script>
	<script language="javascript" type="text/javascript" src="../js/datepicker/WdatePicker.js"></script>
	<script language="javascript" type="text/javascript" src="../js/jquery-1.9.1.min.js"></script>
	<script language="javascript" type="text/javascript" src="../js/clipboard.min.js"></script>
	<script type="text/javascript">
		function change(id) {
			window.location.href = "payLogForm.<%=GCPConstant.PAGE_SUFFIX%>?id=" + id;
		}
		function del(id) {
			if (confirm(lang["70BCL.001"])) {
				document.getElementById("id").value = id;
				document.getElementById("payLogForm").action = "bankCardSettingAction.<%=GCPConstant.PAGE_SUFFIX%>";
				document.getElementById("payLogForm").submit();
			}
		}
		function refer() {
			document.getElementById("payLogForm").submit();
		}

		$("#myTabData .copy_data").hover(function () {
			$(this).html("");
		})
	</script>
</head>

<body>
	<form method="post" id="payLogForm" name="payLogForm" action="pay_log.<%=GCPConstant.PAGE_SUFFIX%>"
		onsubmit="return false;">
		<input type='hidden' id='id' name='id' value='' />
		<input type='hidden' id='oper_type' name='oper_type' value='DEL' />
		<table class="table_nober" width="100%" border="0" align="center" cellpadding="0" cellspacing="0">
			<tr>
				<td class="f_bold f_right" nowrap="nowrap">
					&nbsp;&nbsp;&nbsp;&nbsp;
					<s:text name="订单ID" /><input type='text' id='order_no' name='order_no' size='15' value='<%=orderNo %>' />
					&nbsp;&nbsp;
					<s:text name="玩家账户" /><input type='text' id='user_id' name='user_id' size='15' value='<%=userID %>' />
					&nbsp;&nbsp;
					<s:text name="支付名称" /><input type='text' id='pay_name' name='pay_name' size='15' value='<%=payName %>' />
					&nbsp;&nbsp;
					<s:text name="日志类型" />
					<select style="cursor: pointer;width: 120px;height: 25px" onChange="seachResult()" id="log_type"
						name="log_type">
						<option value="-1" selected="selected">
							<s:text name="全部" />
						</option>
						<option value="0" <%=("0".equals(logType) ? "selected" : "")%>>
							<s:text name="支付请求" />
						</option>
						<option value="1" <%=("1".equals(logType) ? "selected" : "")%>>
							<s:text name="回调请求" />
						</option>
					</select>
					&nbsp;&nbsp;
					<s:text name="请求状态" />
					<select style="cursor: pointer;width: 120px;height: 25px" onChange="seachResult()" id="req_status"
						name="req_status">
						<option value="-1" selected="selected">
							<s:text name="全部" />
						</option>
						<option value="0" <%=("0".equals(reqStatus) ? "selected" : "")%>>
							<s:text name="待处理" />
						</option>
						<option value="1" <%=("1".equals(reqStatus) ? "selected" : "")%>>
							<s:text name="成功" />
						</option>
						<option value="2" <%=("2".equals(reqStatus) ? "selected" : "")%>>
							<s:text name="失败" />
						</option>
					</select>
					&nbsp;&nbsp;
					<s:text name="日志时间" />
					<platform:DateTime size="20" dateFormat="yyyy-MM-dd HH:mm:ss" startName="startDate" endName="endDate"
						startDate='<%=sStartDate%>' endDate="<%=sEndDate%>" />&nbsp;&nbsp;
					&nbsp;<input class="b_2" value=<s:text name="A.015" /> type="button" onclick="refer()" id="save_btn"
					name="save_btn"/>
				</td>
			</tr>
		</table>
		<table id="myTabData" class="myTabData" align="center" border="0" cellspacing="0" cellpadding="0" width="100%"
			style="table-layout:fixed;">
			<tr align="center">
				<th width='5%'>
					<s:text name="订单ID" />
				</th>
				<th width='5%'>
					<s:text name="玩家账户" />
				</th>
				<th width='5%'>
					<s:text name="充值金额" />
				</th>
				<th width='5%'>
					<s:text name="支付名称" />
				</th>
				<th width='5%'>
					<s:text name="二级通道" />
				</th>
				<th width='5%'>
					<s:text name="日志类型" />
				</th>
				<th width='20%'>
					<s:text name="请求参数" />
				</th>
				<th width='20%'>
					<s:text name="响应结果" />
				</th>
				<th width='20%'>
					<s:text name="详细错误" />
				</th>
				<th width='5%'>
					<s:text name="请求状态" />
				</th>
				<th width='5%'>
					<s:text name="日志时间" />
				</th>
			</tr>

			<%
                    if (bankList != null && bankList.length > 0) {
                        String className = "";
                        for (int i = 0; i < bankList.length; i++) {
                            if("dh".equals(className)){
                                className = "sh";
                            }else{
                                className = "dh";
                            }

                            String log_type = "其他";
                            if ("0".equals(bankList[i][LOG_TYPE])) {
                                log_type = "支付请求";
                            } else if ("1".equals(bankList[i][LOG_TYPE])) {
                                log_type = "回调请求";
                            }

                            String req_status = "其他";
                            if ("0".equals(bankList[i][REQ_STATUS])) {
                                req_status = "待处理";
                            } else if ("1".equals(bankList[i][REQ_STATUS])) {
                                req_status = "成功";
                            }else if ("2".equals(bankList[i][REQ_STATUS])) {
                                req_status = "失败";
                            }

                            String channel_name = bankList[i][CHANNEL_NAME];
                            if (StringUtils.isBlank(channel_name)) {
                                channel_name = "-";
                            }

                            out.println("<tr align=\"center\" class=\""+className+"\">");
                            out.println("<td>"+bankList[i][ORDER_NO]+"</td>");
                            out.println("<td>"+bankList[i][USER_ID]+"</td>");
                            out.println("<td>"+bankList[i][TRADE_AMT]+"</td>");
                            out.println("<td>"+bankList[i][PAY_NAME]+"</td>");
                            out.println("<td>"+ channel_name +"</td>");
                            out.println("<td>" + log_type + "</td>");
                            out.println("<td class='copy_td_web'><div class='opacy_div_web'><span>点击复制全部</span><textarea class='texterat_hide' cols='30' rows='10'>"+bankList[i][REQ_PARAM]+"</textarea></div><div class='box_json_web'></div></td>");
                            out.println("<td class='copy_td_web'><div class='opacy_div_web'><span>点击复制全部</span><textarea class='texterat_hide' cols='30' rows='10'>"+bankList[i][RESP_PARAM]+"</textarea></div><div class='box_json_web'></div></td>");
                            out.println("<td class='copy_td_web'><div class='opacy_div_web'><span>点击复制全部</span><textarea class='texterat_hide' cols='30' rows='10'>"+bankList[i][ERROR_DETAILED]+"</textarea></div><div class='box_json_web'></div></td>");

                            out.println("<td>"+req_status+"</td>");
                            out.println("<td>"+Date2.formatDateTime(bankList[i][LOG_DATE],"yyyy-MM-dd HH:mm:ss","yyyy-MM-dd HH:mm:ss")+"</td>");
                            out.println("</tr>");
                        }
                    } else {
                        out.println("<tr align=\"center\">");
                        out.println("<td colspan='14'>"+rb.getString("A.024")+"</td>");
                        out.println("</tr>");
			        }
                %>
			<tr class="page" align='center'>
				<td colspan='14' style='height:35px'>
					<p:PageSelect formName="payLogForm" pageCount="<%=iPageCount%>" totalCount="<%=totalCount%>"
						curPage="<%=iCurPage%>" showTip="true"
						tip='<%="<label id=\\"page_tip\\">"+Lang2.getText(rb,"A.005","%TOTAL_COUNT%","%CUR_PAGE%","%PAGE_COUNT%")+ " </label>"%>'
						listSize="5" showGoToPage="true" showPageCount="true" showOkBtn="true" />

				</td>
			</tr>
		</table>
	</form>
</body>
<script type="text/javascript">
	tabhover('myTabData', '<%=hover%>', '', '', ',dh,sh,');
</script>
<script type="text/javascript">
	// 复制需求
	$(function () {
		// 函数节流
		function throttle(method, delay) {
			var timer = null;
			return function () {
				var context = this, args = arguments;
				clearTimeout(timer);
				timer = setTimeout(function () {
					method.apply(context, args);
				}, delay);
			}
		}
		//  初始化  参数：jsonBoxClass：显示数据div的类名，opactyBoxClass：显示阴影div的类名，hoverClass:鼠标经过td时加在td上的类名
		function initEllipsis(jsonBoxClass, opactyBoxClass, hoverClass) {
			var DisplayTid;
			var divWrapper = $('<div id="init_Ellipsis_Div_Box"></div>');
			divWrapper.css({
				"position": "absolute",
				"z-index": "-1",
				"display": "none",
				"word-break": "break-all"
			})
			// 显示溢出Ellipsis
			$('.' + jsonBoxClass).each(function () {
				var _that = $(this);
				// 当前元素的data，高度，宽度
				var height = _that.height(),
					width = _that.width(),
					allText = _that.closest("td").find("textarea").eq(0).val(),
					lengthText = String(allText).length;
                _that.text(allText);
				divWrapper.css({
					"width": width
				})
				divWrapper.html(allText)
				divWrapper.appendTo(_that);

				var afterHtml = allText;
				var first = true;
				// 计算截取的是字节长度
				setTimeout(function () {
					computerHeight(divWrapper, afterHtml, height);
					function computerHeight(wrapper, text, height) {
						// 获取高度
						wrapper.html(text)
						var wrapheight = wrapper.height()
						var num = wrapheight - height;
						// 首次计算
						if (first) {
							lengthText = Math.ceil(height * lengthText / wrapheight) + Math.ceil(height * 0.35);
							first = false
						}
						// 递归计算
						lengthText = lengthText - 3;
						if (num > 0) {
							afterHtml = text.substr(0, lengthText) + '...';
							computerHeight(wrapper, afterHtml, height)
						} else {
							_that.html(afterHtml)
						}
					}
				}, 0)
			});
			// 显示复制
			$('.' + jsonBoxClass).hover(
				function () {
					var that = $(this);
					DisplayTid = setTimeout(function () {
						$(this).closest("table").find("td").removeClass(hoverClass);
						that.closest("td").addClass(hoverClass);
					}, 100);
				},
				function () {
					clearTimeout(DisplayTid)
				}
			);
			// 隐藏复制
			$("." + opactyBoxClass).hover(
				function () {

				},
				function () {
					$(this).closest("table").find("td").removeClass(hoverClass);
					$("." + opactyBoxClass + ' span').html('点击复制全部');
				}
			)
			// 点击复制
			var clipboard = new ClipboardJS("." + opactyBoxClass + ' span', {
				target: function (trigger) {
					return trigger.nextElementSibling;
				}
			});
			clipboard.on('success', function (e) {
				$(e.trigger).html("复制成功")
				e.clearSelection();
			});
			clipboard.on('error', function (e) {
				$(e.trigger).html("复制失败，请尝试换成chrome浏览器")
				e.clearSelection();
			});
		}
		// 初始化
		initEllipsis("box_json_web", "opacy_div_web", "hover_display_web");
	})
</script>

</html>