# ``ITagNfcFramework``

<!--@START_MENU_TOKEN@-->Summary<!--@END_MENU_TOKEN@-->
ITagNfcFramework is a framework that contains all the necessary assets and user interfaces to integrate with the iTag
through NFC (Near Field Communication).

## Overview

<!--@START_MENU_TOKEN@-->Text<!--@END_MENU_TOKEN@-->
This framework provides a three-method interface where the client can integrate to get/update the iTag information.

- getFlightData: This method allows the user to obtain the current information in the iTag. This includes: passenger name, flight number, flight date,
    barcode, etc.
- updateData: This method allows the user to update the iTag.
- updateLayout: This method allows the user to update the iTag layout. This will be more useful for passengers that have more than one flight.

