/*
Quick tool for uploading multiple spritesheets from Rbx_CustomFont to the website.
After uploading check the chrome dev console to get your asset ids. Credit for this mostly
goes to Seranok as I took his plugin from the webstore and made slight adjustments to it to fit
my purposes.

This tool is likely error prone, but it's not meant to be perfect, just a quick way to automate this annoying
aspect of uploading fonts.
*/

// assetId grabber

function getProductInfo(id) {
	var request = new XMLHttpRequest();
	request.open("GET", "https://api.roblox.com/Marketplace/ProductInfo?assetId=" + id, false);
	request.send();
	var response = request.responseText;
	response = JSON.parse(response);
	return response;
}

function getAssetId(url, tries) {
	var matches = url.match(/\d+/g);
	var id = Number(matches[matches.length - 1]);
	var product = getProductInfo(id);
	function checkId(cid) {
		cproduct = getProductInfo(cid);
		if (cproduct.Name == product.Name && cproduct.AssetTypeId == 1 && cproduct.Creator.Id == product.Creator.Id) {
			return cid;
		}
		if (cid >= (id - tries)) {
			return checkId(cid - 1);
		}
		else {
			return "COULDN'T FIND ASSETID";
		}
	}
	return checkId(id - 1);
}

// I took this from Seranok's plugin:
// https://chrome.google.com/webstore/detail/roblox-upload-enhancer/hddnfljcdedbkkibhmiflkehjnnjmaib

var assetTypeIds = [
	'13'  // Decals
];
var assetTypeId = document.getElementById('assetTypeId').value;
var onDevelopPage = window.parent.location.pathname.indexOf('/develop') == 0;
if (assetTypeIds.indexOf(assetTypeId) >= 0) {

	$('#upload-button')
		.parent()
		.append('<div id="success-count" class="status-confirm btn-level-element" style="display:none">')
		.append('<div id="error-count" class="status-error btn-level-element" style="display:none">');

	window.parent.scrolling = 'yes';
	var fileInput = document.getElementById('file');
	fileInput.multiple = 'multiple';
	var label = document.getElementsByTagName('label')[0];
	label.innerText = 'Find your image(s):';
	document.getElementById('container').removeChild(document.getElementById('name').parentNode);

	$('#upload-button').click(function() {
		var assetTypeId = document.getElementById('assetTypeId').value;
		var groupId = document.getElementById('groupId').value;
		var requestVerificationToken = document.getElementsByName('__RequestVerificationToken')[0].value;
		var files = document.getElementById('file').files;

		$('#loading-container').show();
		$('#success-count').hide();
		$('#error-count').hide();
		var successCount = 0;
		var errorCount = 0;

		var cboardids = [];
		
		for (var i = 0; i < files.length; i++) (function(i) {
			var data = new FormData();
			data.append('assetTypeId', assetTypeId);
			data.append('groupId', groupId);
			data.append('__RequestVerificationToken', requestVerificationToken);
			data.append('file', files[i], files[i].name);
			var fileNameWithoutExtension = files[i].name.split('.')[0]; // everything up to the first period
			data.append('name', fileNameWithoutExtension);

			$.ajax({
				type: 'POST',
				url: '/build/upload',
				data: data,
				contentType: false,
				processData: false,
				success: function(html) {
					var result = $(html).find('#upload-result');
					$('#loading-container').hide();
					if (result.hasClass('status-confirm')) {
						successCount++;
						var successUrl = '/develop'
						if (groupId > 0) {
							successUrl += '/groups/' + groupId;
						}
						successUrl += '?View=' + assetTypeId;
						if (groupId > 0 && !onDevelopPage && assetTypeId != '13') {
							successUrl = $('a:contains("all group items")', window.parent.document).attr('href');
						}
						$('#success-count').html('<a href="' + successUrl + '">' + successCount + ' successful uploads</a>');
						$('#success-count').click(function() {
							window.top.location.href = successUrl;
						});
						$('#success-count').css('display', 'inline-block');
						
						// get the assetid of the image
						var assetid = getAssetId(result[0].innerHTML, 10);
						var indexmatches = files[i].name.match(/\d+/g);
						var indexid = Number(indexmatches[indexmatches.length - 1]);
						cboardids[indexid - 1] = assetid;
					} else {
						errorCount++;
						$('#error-count').text(errorCount + ' failed uploads');
						$('#error-count').show();
					}
					if (successCount + errorCount == files.length && successCount > 0 && onDevelopPage) {
						// we're on the develop page, refresh the view
						var url = '/build/assets?assetTypeId=' + assetTypeId;
						if (groupId) {
							url += '&groupId=' + groupId;
						}
						url += '&_=' + new Date().getTime();
						$('.tab-active .items-container', window.parent.document).load(url);
					}
				}
			});
		})(i);
		
		$(document).ajaxStop(function () {
			var cboard = "module.atlases = {"
			for (var i = 0; i < cboardids.length; i++){
				cboard += "\n\t[" + (i + 1) + "] = \"rbxassetid://" + cboardids[i] + "\";";
			}
			cboard += "\n}";
			console.log(cboard);
		});
	});
}