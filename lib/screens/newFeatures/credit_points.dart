import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CreditPointsScreen extends StatefulWidget {
  const CreditPointsScreen({super.key});

  @override
  State<CreditPointsScreen> createState() => _CreditPointsScreenState();
}

class _CreditPointsScreenState extends State<CreditPointsScreen> {
    int _totalCredits = 0;
    int _totalWithdrawn = 0;
     bool _isLoading = true;


   @override
  void initState() {
    super.initState();
    _fetchCreditData();
  }


  Future<void> _fetchCreditData() async {
       setState(() {
      _isLoading = true;
    });
    try{
     final user = FirebaseAuth.instance.currentUser;
      if(user == null){
         return;
        }
      final userEmail = user.email;

      final userSnapshot = await FirebaseFirestore.instance
        .collection('Users')
         .where('user_email', isEqualTo: userEmail)
        .get();


       if (userSnapshot.docs.isNotEmpty) {
          final userData = userSnapshot.docs.first;
         setState(() {
             _totalCredits = (userData['recycle_award'] ?? 0).toInt() ;
          });
          }

       final submissionsQuery = await FirebaseFirestore.instance
       .collection('Submissions')
       .where('user_email', isEqualTo: userEmail)
       .where('status', whereIn:['accepted','rewarded'])
       .get();


       int withdrawnCredits = 0;
    for (var doc in submissionsQuery.docs) {
       if (doc['status'] == 'rewarded') {
            final docId = doc.id;
              final withdrawSnapshot = await FirebaseFirestore.instance
                  .collection('Withdrawals')
                .where('submission_id', isEqualTo: docId).get();

              if (withdrawSnapshot.docs.isNotEmpty){
                withdrawnCredits +=100;
                print(withdrawnCredits);
              }
          }
       }

           setState(() {
               _totalWithdrawn = withdrawnCredits;
           });



     }
        catch (e){
            print("Error: $e");
         }
         finally{
             setState(() {
               _isLoading=false;
              });
         }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
           title: const Text('Credit points',
               style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        body: _isLoading ? const Center(child: CircularProgressIndicator()) : Padding(
          padding: const EdgeInsets.all(16.0),
           child: Center(
           child:  Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
             Container(
                decoration: BoxDecoration(
                  
                color: const Color.fromARGB(255, 178, 176, 176),
                     borderRadius: BorderRadius.circular(5.0),
                  ),
                 padding: const EdgeInsets.all(20),
                   child: Column(
                       mainAxisAlignment: MainAxisAlignment.center,
                     children: [
                            const Text(
                              'Total credits earned :',
                             
                                style:TextStyle(fontWeight: FontWeight.bold),
                                
                               textAlign: TextAlign.center,
                              
                               
                             ),
                            Text(
                                '$_totalCredits',
                               style: Theme.of(context).textTheme.displayMedium,
                            textAlign: TextAlign.center,

                           ),
                       const SizedBox(height: 10),
                        const Text(
                            '1 CREDIT = Rs.1',
                             style: TextStyle(fontSize: 16, color: Color.fromARGB(255, 50, 123, 53),fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                         ),
                         const SizedBox(height: 10),
                            Text(
                              'Total withdrawn : $_totalWithdrawn',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                             ),
                     ],
                   ),
              ),
            const SizedBox(height: 20),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                      ),
                    onPressed: () {
                         //  Navigator.of(context).push(
                        //    MaterialPageRoute(builder: (context) => WithdrawScreen(totalCredits: totalCredits,)),
                         //  );
                     },
                   child: const Text('Withdraw'),
                    ),
           ],
          ),
          ),
        ),
    );
  }
}