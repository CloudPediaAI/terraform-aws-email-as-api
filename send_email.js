// Import required AWS SDK clients and commands for SES functionalities
const { SESClient, SendEmailCommand } = require("@aws-sdk/client-ses");

async function sendEmail(toAddress, params, errorCallback) {
  const sesClient = new SESClient({ region: process.env.CURRENT_REGION });
  try {
    const command = new SendEmailCommand(params);
    const response = await sesClient.send(command);
    if (!response || !response.MessageId) {
      errorCallback(new Error("No message response from SES."), 500);
    } else {
      return { MessageId: response.MessageId };
    }
  } catch (err) {
    errorCallback(err, 500);
  }
}

function getParamValue(params, paramName, isRequired, errorCallback) {
  var paramValue = null;
  if (params) {
    paramValue = params[paramName];
  }
  if (paramValue) {
    return paramValue;
  } else {
    if (isRequired) {
      errorCallback(new Error("Value for <" + paramName + "> not provided"), 400);
    } else {
      return null;
    }
  }
}

function getParamValueNumeric(params, paramName, isRequired, errorCallback) {
  var paramValue = null;
  if (params) {
    paramValue = params[paramName];
  }
  if (typeof paramValue != "number") {
    if (isRequired) {
      errorCallback(new Error("Value for <" + paramName + "> not provided"), 400);
    } else {
      return null;
    }
  } else {
    return paramValue;
  }
}

exports.handler = async function (event, context, callback) {
  const errorCallback = (err, code) => callback(JSON.stringify({
    errorCode: code ? code : 400,
    errorMessage: err ? err.message : err
  }));

  try {
    const successCallback = (results) => callback(null,
      {
        isBase64Encoded: true,
        statusCode: 200,
        body: JSON.stringify(results),
        headers: {
          'Content-Type': 'application/json',
          'Access-Control-Allow-Headers': 'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token',
          'Access-Control-Allow-Methods': 'GET,OPTIONS,POST,PUT',
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Max-Age': '3600'
        }
      });

    // The FromAddress must be verified in SES.
    const fromAddress = process.env.FROM_EMAIL_ID;

    var httpMethod = getParamValue(event, "httpMethod", true, errorCallback);
    if (httpMethod == "ERROR-BODY") {
      errorCallback(new Error("Request body is not a valid JSON"), 400);
    }
    var payload = getParamValue(event, "body", true, errorCallback);

    // get values from payload
    var toAddress = getParamValue(payload, "recipient", true, errorCallback);
    var subject = getParamValue(payload, "subject", true, errorCallback);
    var body = getParamValue(payload, "body", true, errorCallback);

    // The character encoding for the subject line and message body of the email.
    var charset = "UTF-8";

    const params = {
      Source: fromAddress,
      Destination: {
        ToAddresses: [toAddress],
      },
      Message: {
        Subject: {
          Data: subject,
          Charset: charset,
        },
        Body: {
          Html: {
            Data: body,
            Charset: charset,
          },
          Text: {
            Data: body,
            Charset: charset,
          },
        },
      },
    };

    const res = await sendEmail(toAddress, params, errorCallback);
    successCallback(res);
  } catch (err) {
    errorCallback(err, 500);
  }
};
