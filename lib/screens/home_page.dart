import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return  Column(
      children: [
        Container(
          padding: EdgeInsets.only(
            left: 50,
            right: 50,
          ),
          child: Image.asset('assets/images/logo_letras.png'),
        ),
        Container(
          padding: EdgeInsets.only(
            top: 20,
            left: 50,
            right: 50,
          ),
          child: Image.asset('assets/images/interreg_logo.png'),
        ),
        Container(
          padding: EdgeInsets.only(
            top: 250,
            left: 180,
            right: 50,
            bottom: 10,
          ),
          child: Text("POWERED BY",
            style: TextStyle(
                color: Color(0xFF346cb0),
                fontSize: 10,
                fontWeight: FontWeight.bold),),
        ),
        Container(
          padding: EdgeInsets.only(
            left: 230,
            right: 50,
          ),
          child: Image.asset('assets/images/my_sense.png'),
        ),

      ],
    );
  }
}