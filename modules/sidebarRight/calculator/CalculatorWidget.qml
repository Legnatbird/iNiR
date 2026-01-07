import qs.modules.common
import qs.modules.common.widgets
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root
    focus: true // Enable focus for keyboard input
    implicitHeight: 320 // Provide implicit height for layout calculation
    
    property string displayValue: "0"
    property string expression: ""
    property bool newNumber: true
    property string lastOp: ""
    
    // Keyboard handling
    Keys.onPressed: (event) => {
        switch (event.key) {
            case Qt.Key_0: root.appendDigit("0"); break;
            case Qt.Key_1: root.appendDigit("1"); break;
            case Qt.Key_2: root.appendDigit("2"); break;
            case Qt.Key_3: root.appendDigit("3"); break;
            case Qt.Key_4: root.appendDigit("4"); break;
            case Qt.Key_5: root.appendDigit("5"); break;
            case Qt.Key_6: root.appendDigit("6"); break;
            case Qt.Key_7: root.appendDigit("7"); break;
            case Qt.Key_8: root.appendDigit("8"); break;
            case Qt.Key_9: root.appendDigit("9"); break;
            case Qt.Key_Period: root.appendDigit("."); break;
            case Qt.Key_Plus: root.appendOperator("+"); break;
            case Qt.Key_Minus: root.appendOperator("-"); break;
            case Qt.Key_Asterisk: root.appendOperator("*"); break;
            case Qt.Key_Slash: root.appendOperator("/"); break;
            case Qt.Key_Enter: 
            case Qt.Key_Return: root.calculate(); break;
            case Qt.Key_Backspace: 
                if (root.displayValue.length > 1) {
                    root.displayValue = root.displayValue.slice(0, -1);
                } else {
                    root.displayValue = "0";
                    root.newNumber = true;
                }
                break;
            case Qt.Key_Escape: root.clear(); break;
        }
        event.accepted = true;
    }

    // Logic for calculator
    function appendDigit(digit) {
        if (root.newNumber) {
            root.displayValue = digit
            root.newNumber = false
        } else {
            if (root.displayValue === "0" && digit !== ".")
                root.displayValue = digit
            else
                root.displayValue += digit
        }
    }

    function appendOperator(op) {
        root.expression += root.displayValue + op
        root.newNumber = true
        root.lastOp = op
    }

    function calculate() {
        try {
            let finalExpr = root.expression + root.displayValue
            // Basic sanitization: only allow digits and operators
            finalExpr = finalExpr.replace(/[^-()\d/*+.]/g, '');
            // Evaluate
            // eslint-disable-next-line
            let result = eval(finalExpr) 
            
            // Format result
            if (!isFinite(result)) {
                root.displayValue = "Error"
            } else {
                // Limit decimals
                let resultStr = result.toString()
                if (resultStr.length > 12) {
                    resultStr = result.toPrecision(10)
                }
                root.displayValue = resultStr
            }
            root.expression = ""
            root.newNumber = true
        } catch (e) {
            root.displayValue = "Error"
            root.expression = ""
            root.newNumber = true
        }
    }

    function clear() {
        root.displayValue = "0"
        root.expression = ""
        root.newNumber = true
    }

    function toggleSign() {
        if (root.displayValue !== "0" && root.displayValue !== "Error") {
            if (root.displayValue.startsWith("-"))
                root.displayValue = root.displayValue.substring(1)
            else
                root.displayValue = "-" + root.displayValue
        }
    }

    function percent() {
        let val = parseFloat(root.displayValue)
        root.displayValue = (val / 100).toString()
    }

    component CalcButton: RippleButton {
        required property string label
        property bool accent: false
        property bool secondary: false
        
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.preferredHeight: 50 // Fixed height for square-ish buttons
        
        buttonText: label
        
        // Custom styling for calculator buttons
        colBackground: accent 
            ? Appearance.colors.colPrimary 
            : secondary 
                ? (Appearance.inirEverywhere ? Appearance.inir.colLayer2 
                    : Appearance.auroraEverywhere ? Appearance.aurora.colSubSurface
                    : Appearance.colors.colLayer2)
                : (Appearance.inirEverywhere ? Appearance.inir.colLayer1 
                    : Appearance.auroraEverywhere ? "transparent"
                    : Appearance.colors.colLayer1)
                
        colBackgroundHover: accent 
            ? Appearance.colors.colPrimaryHover 
            : secondary
                ? (Appearance.inirEverywhere ? Appearance.inir.colLayer2Hover 
                    : Appearance.auroraEverywhere ? Appearance.aurora.colElevatedSurface
                    : Appearance.colors.colLayer2Hover)
                : (Appearance.inirEverywhere ? Appearance.inir.colLayer1Hover 
                    : Appearance.auroraEverywhere ? Appearance.aurora.colSubSurface
                    : Appearance.colors.colLayer1Hover)
                
        // Override contentItem to handle text color
        contentItem: StyledText {
            text: parent.buttonText
            font: parent.font
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            color: parent.accent 
                ? Appearance.colors.colOnPrimary 
                : (Appearance.inirEverywhere ? Appearance.inir.colText 
                    : Appearance.colors.colOnLayer1)
        }
        
        font.pixelSize: Appearance.font.pixelSize.large
        
        // Inir styling
        buttonRadius: Appearance.inirEverywhere ? Appearance.inir.roundingSmall : Appearance.rounding.small
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 10

        // Display Area
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 80
            
            color: Appearance.inirEverywhere ? Appearance.inir.colLayer0 
                 : Appearance.auroraEverywhere ? Appearance.aurora.colSubSurface 
                 : Appearance.colors.colLayer0
                 
            radius: Appearance.inirEverywhere ? Appearance.inir.roundingNormal : Appearance.rounding.normal
            border.width: Appearance.inirEverywhere ? 1 : 0
            border.color: Appearance.inirEverywhere ? Appearance.inir.colBorder : "transparent"
            
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 15
                spacing: 0
                
                // History / Expression
                StyledText {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignRight
                    text: root.expression.replace(/\*/g, "×").replace(/\//g, "÷")
                    horizontalAlignment: Text.AlignRight
                    color: Appearance.colors.colSubtext
                    font.pixelSize: Appearance.font.pixelSize.small
                }
                
                // Main Value
                StyledText {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.alignment: Qt.AlignRight
                    text: root.displayValue
                    horizontalAlignment: Text.AlignRight
                    color: Appearance.inirEverywhere ? Appearance.inir.colText 
                         : Appearance.colors.colOnLayer0
                    font.pixelSize: 32
                    fontSizeMode: Text.Fit
                    minimumPixelSize: 16
                }
            }
        }

        // Keypad
        GridLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            columns: 4
            rowSpacing: 6
            columnSpacing: 6

            // Row 1
            CalcButton { label: "C"; secondary: true; onClicked: root.clear() }
            CalcButton { label: "+/-"; secondary: true; onClicked: root.toggleSign() }
            CalcButton { label: "%"; secondary: true; onClicked: root.percent() }
            CalcButton { 
                label: "÷"; accent: true
                colBackground: Appearance.colors.colSecondary 
                colBackgroundHover: Appearance.colors.colSecondaryHover
                onClicked: root.appendOperator("/") 
            }

            // Row 2
            CalcButton { label: "7"; onClicked: root.appendDigit("7") }
            CalcButton { label: "8"; onClicked: root.appendDigit("8") }
            CalcButton { label: "9"; onClicked: root.appendDigit("9") }
            CalcButton { 
                label: "×"; accent: true
                colBackground: Appearance.colors.colSecondary
                colBackgroundHover: Appearance.colors.colSecondaryHover
                onClicked: root.appendOperator("*") 
            }

            // Row 3
            CalcButton { label: "4"; onClicked: root.appendDigit("4") }
            CalcButton { label: "5"; onClicked: root.appendDigit("5") }
            CalcButton { label: "6"; onClicked: root.appendDigit("6") }
            CalcButton { 
                label: "-"; accent: true
                colBackground: Appearance.colors.colSecondary
                colBackgroundHover: Appearance.colors.colSecondaryHover
                onClicked: root.appendOperator("-") 
            }

            // Row 4
            CalcButton { label: "1"; onClicked: root.appendDigit("1") }
            CalcButton { label: "2"; onClicked: root.appendDigit("2") }
            CalcButton { label: "3"; onClicked: root.appendDigit("3") }
            CalcButton { 
                label: "+"; accent: true
                colBackground: Appearance.colors.colSecondary
                colBackgroundHover: Appearance.colors.colSecondaryHover
                onClicked: root.appendOperator("+") 
            }

            // Row 5
            CalcButton { 
                label: "0"
                Layout.columnSpan: 2
                onClicked: root.appendDigit("0") 
            }
            CalcButton { label: "."; onClicked: root.appendDigit(".") }
            CalcButton { label: "="; accent: true; onClicked: root.calculate() }
        }
    }
}
