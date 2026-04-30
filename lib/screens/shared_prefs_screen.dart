import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
class SharedPrefsScreen extends StatefulWidget
{
  const SharedPrefsScreen({super.key});
  @override
  State<SharedPrefsScreen> createState()=>_SharedPrefsScreenState();
}
class _SharedPrefsScreenState extends State<SharedPrefsScreen>
{
  final _nameController=TextEditingController();
  final _ageController=TextEditingController();
  final _emailController=TextEditingController();
  final _formKey=GlobalKey<FormState>();
  String? _savedName;
  String? _savedAge;
  String? _savedEmail;
  String? _savedAt;
  bool _isSaving=false;
  bool _isLoading=false;
  @override
  void dispose()
  {
    _nameController.dispose();
    _ageController.dispose();
    _emailController.dispose();
    super.dispose();
  }
  Future<void> _saveName() async
  {
    if(!_formKey.currentState!.validate()) return;
    setState(()=>_isSaving=true);
    final prefs=await SharedPreferences.getInstance();
    final now=DateTime.now();
    final timestamp=
        '${now.day}/${now.month}/${now.year} ${now.hour.toString().padLeft(2,'0')}:${now.minute.toString().padLeft(2,'0')}:${now.second.toString().padLeft(2,'0')}';
    await prefs.setString('username',_nameController.text.trim());
    await prefs.setString('age',_ageController.text.trim());
    await prefs.setString('email',_emailController.text.trim());
    await prefs.setString('savedAt',timestamp);
    setState(()=>_isSaving=false);
    if(mounted)
    {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:const Row(
            children:
            [
              Icon(Icons.check_circle,color:Colors.white),
              SizedBox(width:8),
              Text('Data saved successfully!'),
            ],
          ),
          backgroundColor:Colors.green.shade700,
          behavior:SnackBarBehavior.floating,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }
  Future<void> _showName() async
  {
    setState(()=>_isLoading=true);
    final prefs=await SharedPreferences.getInstance();
    setState(()
    {
      _savedName=prefs.getString('username');
      _savedAge=prefs.getString('age');
      _savedEmail=prefs.getString('email');
      _savedAt=prefs.getString('savedAt');
      _isLoading=false;
    });
  }
  Future<void> _clearData() async
  {
    final confirm=await showDialog<bool>(
      context:context,
      builder:(ctx) => AlertDialog(
        title:const Text('Clear Data'),
        content:
        const Text('Are you sure you want to remove all saved data?'),
        actions:
        [
          TextButton(
              onPressed:()=>Navigator.pop(ctx,false),
              child:const Text('Cancel')),
          FilledButton(
            onPressed:()=>Navigator.pop(ctx,true),
            style:FilledButton.styleFrom(backgroundColor:Colors.red),
            child:const Text('Clear'),
          ),
        ],
      ),
    );
    if(confirm!=true) return;
    final prefs=await SharedPreferences.getInstance();
    await prefs.remove('username');
    await prefs.remove('age');
    await prefs.remove('email');
    await prefs.remove('savedAt');
    setState(()
    {
      _savedName=null;
      _savedAge=null;
      _savedEmail=null;
      _savedAt=null;
    });
    _nameController.clear();
    _ageController.clear();
    _emailController.clear();
    if(mounted)
    {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:const Text('Data cleared!'),
          behavior:SnackBarBehavior.floating,
          shape:
          RoundedRectangleBorder(borderRadius:BorderRadius.circular(12)),
        ),
      );
    }
  }
  @override
  Widget build(BuildContext context)
  {
    final colorScheme=Theme.of(context).colorScheme;
    return Scaffold(
      appBar:AppBar(
        title:const Text('Exercise 3 — Shared Preferences'),
        backgroundColor:colorScheme.surfaceContainer,
      ),
      body:SingleChildScrollView(
        padding:const EdgeInsets.all(20),
        child:Form(
          key:_formKey,
          child:Column(
            crossAxisAlignment:CrossAxisAlignment.stretch,
            children:
            [
              Card(
                elevation:0,
                shape:RoundedRectangleBorder(
                  borderRadius:BorderRadius.circular(16),
                  side:BorderSide(color:colorScheme.outlineVariant),
                ),
                child:Padding(
                  padding:const EdgeInsets.all(20),
                  child:Column(
                    crossAxisAlignment:CrossAxisAlignment.start,
                    children:
                    [
                      Row(
                        children:
                        [
                          Icon(Icons.edit_note,
                              color:colorScheme.primary),
                          const SizedBox(width:8),
                          const Text('Enter Data',
                              style:TextStyle(
                                  fontWeight:FontWeight.bold,
                                  fontSize:16)),
                        ],
                      ),
                      const SizedBox(height:20),
                      TextFormField(
                        controller:_nameController,
                        decoration:InputDecoration(
                          labelText:'Name *',
                          hintText:'Enter your name',
                          prefixIcon:const Icon(Icons.person_outline),
                          border:OutlineInputBorder(
                              borderRadius:BorderRadius.circular(12)),
                          filled:true,
                        ),
                        validator:(val)
                        {
                          if(val==null||val.trim().isEmpty)
                          {
                            return 'Name is required';
                          }
                          return null;
                        },
                        textInputAction:TextInputAction.next,
                      ),
                      const SizedBox(height:14),
                      TextFormField(
                        controller:_ageController,
                        decoration:InputDecoration(
                          labelText:'Age (Bonus)',
                          hintText:'Enter your age',
                          prefixIcon:
                          const Icon(Icons.cake_outlined),
                          border:OutlineInputBorder(
                              borderRadius:BorderRadius.circular(12)),
                          filled:true,
                          suffixText:'years',
                        ),
                        keyboardType:TextInputType.number,
                        textInputAction:TextInputAction.next,
                      ),
                      const SizedBox(height:14),
                      TextFormField(
                        controller:_emailController,
                        decoration:InputDecoration(
                          labelText:'Email (Bonus)',
                          hintText:'Enter your email',
                          prefixIcon:
                          const Icon(Icons.email_outlined),
                          border:OutlineInputBorder(
                              borderRadius:BorderRadius.circular(12)),
                          filled:true,
                        ),
                        keyboardType:TextInputType.emailAddress,
                        textInputAction:TextInputAction.done,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height:16),
              Row(
                children:
                [
                  Expanded(
                    flex:2,
                    child:FilledButton.icon(
                      onPressed:_isSaving?null:_saveName,
                      icon:_isSaving?const SizedBox(
                          width:16,
                          height:16,
                          child:CircularProgressIndicator(
                              strokeWidth:2,color:Colors.white))
                          : const Icon(Icons.save),
                      label:Text(_isSaving?'Saving...':'Save Name'),
                      style:FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical:14)),
                    ),
                  ),
                  const SizedBox(width:10),
                  Expanded(
                    flex:2,
                    child:FilledButton.tonal(
                      onPressed:_isLoading?null:_showName,
                      style:FilledButton.styleFrom(
                          padding:const EdgeInsets.symmetric(vertical:14)),
                      child:Row(
                        mainAxisAlignment:MainAxisAlignment.center,
                        children:
                        [
                          _isLoading?const SizedBox(
                              width:16,
                              height:16,
                              child:CircularProgressIndicator(
                                  strokeWidth:2))
                              :const Icon(Icons.visibility),
                          const SizedBox(width:8),
                          Text(_isLoading?'Loading...':'Show Name'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width:10),
                  IconButton.outlined(
                    onPressed:_clearData,
                    icon:const Icon(Icons.delete_outline,color:Colors.red),
                    tooltip:'Clear saved data',
                    style:IconButton.styleFrom(
                      side:const BorderSide(color:Colors.red),
                      padding:const EdgeInsets.all(14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height:24),
              _SavedDataCard(
                savedName:_savedName,
                savedAge:_savedAge,
                savedEmail:_savedEmail,
                savedAt:_savedAt,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
class _SavedDataCard extends StatelessWidget
{
  final String? savedName;
  final String? savedAge;
  final String? savedEmail;
  final String? savedAt;
  const _SavedDataCard({
    this.savedName,
    this.savedAge,
    this.savedEmail,
    this.savedAt,
  });
  @override
  Widget build(BuildContext context)
  {
    final colorScheme=Theme.of(context).colorScheme;
    final hasData=savedName!=null;
    return AnimatedContainer(
      duration:const Duration(milliseconds:300),
      padding:const EdgeInsets.all(20),
      decoration:BoxDecoration(
        color:hasData?colorScheme.primaryContainer.withOpacity(0.4)
            :colorScheme.surfaceContainer,
        borderRadius:BorderRadius.circular(16),
        border:Border.all(
          color:hasData?colorScheme.primary.withOpacity(0.3):colorScheme.outlineVariant,
        ),
      ),
      child:!hasData?Row(
        children:[
          Icon(Icons.info_outline,
              color:colorScheme.onSurfaceVariant),
          const SizedBox(width:12),
          Text(
            'No saved data. Press "Show Name" to retrieve.',
            style: TextStyle(color:colorScheme.onSurfaceVariant),
          ),
        ],
      )
          :Column(
        crossAxisAlignment:CrossAxisAlignment.start,
        children:
        [
          Row(
            children:
            [
              Icon(Icons.storage,color:colorScheme.primary,size:18),
              const SizedBox(width:8),
              Text(
                'Saved Data (SharedPreferences)',
                style:TextStyle(
                  color:colorScheme.primary,
                  fontWeight:FontWeight.bold,
                  fontSize:13,
                ),
              ),
            ],
          ),
          const SizedBox(height:16),
          _DataRow(label:'Name',value:savedName!,icon:Icons.person),
          if(savedAge!=null&&savedAge!.isNotEmpty)
            _DataRow(label:'Age',value:'$savedAge years',icon:Icons.cake),
          if(savedEmail!=null&&savedEmail!.isNotEmpty)
            _DataRow(label:'Email',value:savedEmail!,icon:Icons.email),
          if(savedAt!=null) ...
          [
            const Divider(height:20),
            Row(
              children:
              [
                Icon(Icons.schedule,
                    size:14,
                    color:colorScheme.onSurfaceVariant),
                const SizedBox(width:6),
                Text(
                  'Last saved:$savedAt',
                  style:TextStyle(
                    fontSize:11,
                    color:colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
class _DataRow extends StatelessWidget
{
  final String label;
  final String value;
  final IconData icon;
  const _DataRow({required this.label,required this.value,required this.icon});
  @override
  Widget build(BuildContext context)
  {
    return Padding(
      padding:const EdgeInsets.symmetric(vertical:6),
      child:Row(
        children:[
          Icon(icon,
              size:16,
              color:Theme.of(context).colorScheme.onSurfaceVariant),
          const SizedBox(width:10),
          Text('$label: ',
              style:TextStyle(
                  fontSize:13,
                  color:Theme.of(context).colorScheme.onSurfaceVariant)),
          Expanded(
            child:Text(value,
                style:const TextStyle(
                    fontSize:14,fontWeight:FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}