$code = @"
                            const SizedBox(height: 4),
                            SizedBox(
                              height: 40,
                              child: TextField(
                                controller: TextEditingController(
                                  text: _startDate != null ? DateFormat('dd-MM-yyyy').format(_startDate!) : '',
                                ),
                                readOnly: true,
                                onTap: () async {
                                  final DateTime? picked = await showDatePicker(
                                    context: context,
                                    initialDate: _startDate ?? DateTime.now(),
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime(2100),
                                  );
                                  if (picked != null) {
                                    setState(() {
                                      _startDate = picked;
                                    });
                                  }
                                },
                                decoration: InputDecoration(
"@
$code2 = @"
                            const SizedBox(height: 4),
                            SizedBox(
                              height: 40,
                              child: TextField(
                                controller: TextEditingController(
                                  text: _endDate != null ? DateFormat('dd-MM-yyyy').format(_endDate!) : '',
                                ),
                                readOnly: true,
                                onTap: () async {
                                  final DateTime? picked = await showDatePicker(
                                    context: context,
                                    initialDate: _endDate ?? DateTime.now(),
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime(2100),
                                  );
                                  if (picked != null) {
                                    setState(() {
                                      _endDate = picked;
                                    });
                                  }
                                },
                                decoration: InputDecoration(
"@

$content = Get-Content d:\flutterprojects\racpl\lib\screens\features\expense_list_screen.dart -Raw

$content = $content -replace "(?s)START DATE',[\s]*style: TextStyle\([\s]*fontSize: 10,[\s]*color: Colors.grey,[\s]*fontWeight: FontWeight.bold,[\s]*\),[\s]*\),[\s]*const SizedBox\(height: 4\),[\s]*SizedBox\([\s]*height: 40,[\s]*child: TextField\([\s]*readOnly: true,[\s]*decoration: InputDecoration\(", ("START DATE', style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold,),), " + $code)
$content = $content -replace "(?s)END DATE',[\s]*style: TextStyle\([\s]*fontSize: 10,[\s]*color: Colors.grey,[\s]*fontWeight: FontWeight.bold,[\s]*\),[\s]*\),[\s]*const SizedBox\(height: 4\),[\s]*SizedBox\([\s]*height: 40,[\s]*child: TextField\([\s]*readOnly: true,[\s]*decoration: InputDecoration\(", ("END DATE', style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold,),), " + $code2)

Set-Content d:\flutterprojects\racpl\lib\screens\features\expense_list_screen.dart -Value $content
