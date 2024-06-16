import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tidal_wave/shared/function_utils.dart';
import 'dart:math' as math;

import 'package:tidal_wave/shared/widgets/tw_text_field.dart';

class DurationFormField extends StatefulWidget {

  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final bool? enabled;
  final Widget? topText;
  final Duration? maxDuration;

  const DurationFormField({super.key, this.controller, this.validator, this.onChanged, this.enabled = true, this.topText, this.maxDuration});

  @override
  State<DurationFormField> createState() => _DurationFormFieldState();
}

class _DurationFormFieldState extends State<DurationFormField> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          widget.topText ?? const SizedBox.shrink(),
          TWTextField(
            validator: widget.validator,
            controller: widget.controller,
            onChanged: widget.onChanged,
            enabled: widget.enabled,
            textInputType: const TextInputType.numberWithOptions(decimal: false),
            hintText: '00:00:00',
            inputFormatters: <TextInputFormatter>[
              TimeTextInputFormatter()
            ],
            icon: const Icon(Icons.timer_sharp),
          ),
          if(widget.enabled!) Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(onPressed: (){
                  if(widget.controller != null && widget.maxDuration != null && parseDuration(widget.controller!.text) < widget.maxDuration!){
                    widget.controller!.text = toStringDurationFormat(parseDuration(widget.controller!.text) + const Duration(seconds: 1));
                    widget.onChanged!.call(widget.controller!.text);
                  }
                }, style: TextButton.styleFrom(foregroundColor: Colors.white, backgroundColor: Colors.white.withOpacity(0.3)), child: const Text('+1')),
                const SizedBox(width: 10),
                TextButton(onPressed: (){
                  if(widget.controller != null && widget.maxDuration != null && parseDuration(widget.controller!.text) > Duration.zero){
                    widget.controller!.text = toStringDurationFormat(parseDuration(widget.controller!.text) - const Duration(seconds: 1));
                    widget.onChanged!.call(widget.controller!.text);
                  }
                }, style: TextButton.styleFrom(foregroundColor: Colors.white, backgroundColor: Colors.white.withOpacity(0.3)), child: const Text('-1'))
              ],
            ),
          )          
        ],
      ),
    );
  }
}

//? When copias codigo
class TimeTextInputFormatter extends TextInputFormatter {
  late RegExp _exp;
  TimeTextInputFormatter() {
    _exp = RegExp(r'^[0-9:]+$');
  }

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (_exp.hasMatch(newValue.text)) {
      TextSelection newSelection = newValue.selection;

      String value = newValue.text;
      String newText;

      String leftChunk = '';
      String rightChunk = '';

      if (value.length >= 8) {
        if (value.substring(0, 7) == '00:00:0') {
          leftChunk = '00:00:';
          rightChunk = value.substring(leftChunk.length + 1, value.length);
        } else if (value.substring(0, 6) == '00:00:') {
          leftChunk = '00:0';
          rightChunk = "${value.substring(6, 7)}:${value.substring(7)}";
        } else if (value.substring(0, 4) == '00:0') {
          leftChunk = '00:';
          rightChunk = "${value.substring(4, 5)}${value.substring(6, 7)}:${value.substring(7)}";
        } else if (value.substring(0, 3) == '00:') {
          leftChunk = '0';
          rightChunk = "${value.substring(3, 4)}:${value.substring(4, 5)}${value.substring(6, 7)}:${value.substring(7, 8)}${value.substring(8)}";
        } else {
          leftChunk = '';
          rightChunk = "${value.substring(1, 2)}${value.substring(3, 4)}:${value.substring(4, 5)}${value.substring(6, 7)}:${value.substring(7)}";
        }
      } else if (value.length == 7) {
        if (value.substring(0, 7) == '00:00:0') {
          leftChunk = '';
          rightChunk = '';
        } else if (value.substring(0, 6) == '00:00:') {
          leftChunk = '00:00:0';
          rightChunk = value.substring(6, 7);
        } else if (value.substring(0, 1) == '0') {
          leftChunk = '00:';
          rightChunk = "${value.substring(1, 2)}${value.substring(3, 4)}:${value.substring(4, 5)}${value.substring(6, 7)}";
        } else {
          leftChunk = '';
          rightChunk = "${value.substring(1, 2)}${value.substring(3, 4)}:${value.substring(4, 5)}${value.substring(6, 7)}:${value.substring(7)}";
        }
      } else {
        leftChunk = '00:00:0';
        rightChunk = value;
      }

      if (oldValue.text.isNotEmpty && oldValue.text.substring(0, 1) != '0') {
        if (value.length > 7) {
          return oldValue;
        } else {
          leftChunk = '0';
          rightChunk = "${value.substring(0, 1)}:${value.substring(1, 2)}${value.substring(3, 4)}:${value.substring(4, 5)}${value.substring(6, 7)}";
        }
      }

      newText = leftChunk + rightChunk;

      newSelection = newValue.selection.copyWith(
        baseOffset: math.min(newText.length, newText.length),
        extentOffset: math.min(newText.length, newText.length),
      );

      return TextEditingValue(
        text: newText,
        selection: newSelection,
        composing: TextRange.empty,
      );
    }
    return oldValue;
  }
}