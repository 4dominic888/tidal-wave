import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:tidal_wave/modules/lista_musica/widgets/icon_button_music.dart';

class ListaMusicaScreen extends StatefulWidget {
  const ListaMusicaScreen({super.key});

  @override
  State<ListaMusicaScreen> createState() => _ListaMusicaScreenState();
}

class _ListaMusicaScreenState extends State<ListaMusicaScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            IconButtonUIMusic(
              borderColor: Colors.blue.shade400.withAlpha(50),
              borderSize: 4.0,
              fillColor: Colors.transparent,
              icon: const Icon(Icons.menu, size: 25, color: Colors.white),
              onTap: () {},
            ),
            
            const SizedBox(width: 10),
            PreferredSize(
              preferredSize: const Size.fromHeight(kToolbarHeight),
              child: 
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Buscar musica...',
                      hintStyle: const TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.white
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(300),
                        borderSide: const BorderSide(color: Colors.transparent)
                      ),
                      fillColor: const Color.fromRGBO(171, 196, 248, 0.2),
                      filled: true,
                      suffixIcon: const Icon(Icons.search),
                      suffixIconColor: Colors.white,
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(300),
                        borderSide: const BorderSide(color: Color.fromRGBO(171, 196, 248, 0.6))
                      ),
                      contentPadding: const EdgeInsets.all(15),
                    ),
                    autocorrect: false,
                    enableSuggestions: false,
                    cursorColor: Colors.white,
                    style: const TextStyle(color: Colors.white),
                )
              )
            )
        ]),
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color.fromARGB(255, 30, 114, 138),Color(0xFF071A2C)]
          )
        ),
      )
    );
  }
}