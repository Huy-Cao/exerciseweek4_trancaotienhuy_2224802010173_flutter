import 'package:flutter/material.dart';
import '../models/contact.dart';
class ListViewScreen extends StatefulWidget
{
  const ListViewScreen({super.key});
  @override
  State<ListViewScreen> createState()=>_ListViewScreenState();
}
class _ListViewScreenState extends State<ListViewScreen>
{
  String _searchQuery='';
  final TextEditingController _searchController=TextEditingController();
  List<Contact> get _filteredContacts
  {
    if(_searchQuery.isEmpty) return sampleContacts;
    return sampleContacts.where((c)=>c.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        c.phone.contains(_searchQuery)).toList();
  }
  @override
  void dispose()
  {
    _searchController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context)
  {
    final colorScheme=Theme.of(context).colorScheme;
    return Scaffold(
      appBar:AppBar(
        title:const Text('Exercise 1 — List View'),
        backgroundColor:colorScheme.surfaceContainer,
        bottom:PreferredSize(
          preferredSize:const Size.fromHeight(64),
          child:Padding(
            padding:const EdgeInsets.fromLTRB(16,0,16,10),
            child:SearchBar(
              controller:_searchController,
              hintText:'Search contacts...',
              leading:const Icon(Icons.search),
              trailing:
              [
                if(_searchQuery.isNotEmpty)
                  IconButton(
                    icon:const Icon(Icons.clear),
                    onPressed:()
                    {
                      _searchController.clear();
                      setState(()=>_searchQuery='');
                    },
                  ),
              ],
              onChanged:(val)=>setState(()=>_searchQuery=val),
            ),
          ),
        ),
      ),
      body:Column(
        children:
        [
          Container(
            padding:const EdgeInsets.symmetric(horizontal:16,vertical:8),
            color:colorScheme.surfaceContainer.withOpacity(0.4),
            child:Row(
              children:
              [
                Text(
                  '${_filteredContacts.length} contacts',
                  style:TextStyle(
                    fontSize:12,
                    color:colorScheme.onSurfaceVariant,
                    fontWeight:FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child:_filteredContacts.isEmpty
                ?Center(
              child:Column(
                mainAxisSize:MainAxisSize.min,
                children:
                [
                  Icon(Icons.search_off,
                      size:64,
                      color:colorScheme.onSurfaceVariant.withOpacity(0.4)),
                  const SizedBox(height:12),
                  Text(
                    'No contacts found',
                    style:TextStyle(color:colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            )
                :ListView.builder(
              itemCount:_filteredContacts.length,
              itemBuilder:(context,index)
              {
                final contact=_filteredContacts[index];
                return _ContactTile(
                  contact:contact,
                  index:index,
                  onTap:()=>_showContactDetail(context,contact),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton:FloatingActionButton(
        onPressed:()=>_showAddContactDialog(context),
        child:const Icon(Icons.person_add),
      ),
    );
  }
  void _showContactDetail(BuildContext context,Contact contact)
  {
    showModalBottomSheet(
      context:context,
      isScrollControlled:true,
      useSafeArea:true,
      shape:const RoundedRectangleBorder(
        borderRadius:BorderRadius.vertical(top:Radius.circular(20)),
      ),
      builder:(ctx)=>_ContactDetailSheet(contact:contact),
    );
  }
  void _showAddContactDialog(BuildContext context)
  {
    showDialog(
      context:context,
      builder:(ctx)=>AlertDialog(
        title:const Text('Add Contact'),
        content:const Text('In a full app, this would open a form to add a new contact.'),
        actions:
        [
          TextButton(
            onPressed:()=>Navigator.pop(ctx),
            child:const Text('OK'),
          ),
        ],
      ),
    );
  }
}
class _ContactTile extends StatelessWidget
{
  final Contact contact;
  final int index;
  final VoidCallback onTap;
  const _ContactTile({
    required this.contact,
    required this.index,
    required this.onTap,
  });
  Color _avatarColor(BuildContext context)
  {
    final colors=
    [
      Theme.of(context).colorScheme.primaryContainer,
      Theme.of(context).colorScheme.secondaryContainer,
      Theme.of(context).colorScheme.tertiaryContainer,
      Colors.teal.shade100,
      Colors.orange.shade100,
      Colors.pink.shade100,
    ];
    return colors[index%colors.length];
  }
  Color _avatarForeground(BuildContext context)
  {
    final colors=
    [
      Theme.of(context).colorScheme.onPrimaryContainer,
      Theme.of(context).colorScheme.onSecondaryContainer,
      Theme.of(context).colorScheme.onTertiaryContainer,
      Colors.teal.shade800,
      Colors.orange.shade800,
      Colors.pink.shade800,
    ];
    return colors[index%colors.length];
  }
  @override
  Widget build(BuildContext context)
  {
    return Column(
      mainAxisSize:MainAxisSize.min,
      children:
      [
        ListTile(
          onTap:onTap,
          contentPadding:const EdgeInsets.symmetric(horizontal:16,vertical:4),
          leading:Hero(
            tag:'avatar_${contact.name}',
            child:CircleAvatar(
              radius:26,
              backgroundColor:_avatarColor(context),
              backgroundImage:NetworkImage(contact.avatarUrl),
              onBackgroundImageError:(_, __) {},
              child:null,
            ),
          ),
          title:Text(
            contact.name,
            style:const TextStyle(fontWeight:FontWeight.w600,fontSize:15),
          ),
          subtitle:Column(
            crossAxisAlignment:CrossAxisAlignment.start,
            children:
            [
              const SizedBox(height:2),
              Row(
                children:
                [
                  Icon(Icons.phone_outlined,
                      size:12,
                      color:Theme.of(context).colorScheme.onSurfaceVariant),
                  const SizedBox(width:4),
                  Text(contact.phone,style:const TextStyle(fontSize:12)),
                ],
              ),
              Row(
                children:
                [
                  Icon(Icons.email_outlined,
                      size:12,
                      color:Theme.of(context).colorScheme.onSurfaceVariant),
                  const SizedBox(width:4),
                  Text(contact.email,
                      style:const TextStyle(fontSize:12),
                      overflow:TextOverflow.ellipsis),
                ],
              ),
            ],
          ),
          trailing:Row(
            mainAxisSize:MainAxisSize.min,
            children:
            [
              IconButton(
                icon:const Icon(Icons.phone,size:20),
                onPressed:(){},
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
        const Divider(height: 1,indent:80),
      ],
    );
  }
}
class _ContactDetailSheet extends StatelessWidget
{
  final Contact contact;
  const _ContactDetailSheet({required this.contact});
  @override
  Widget build(BuildContext context)
  {
    final colorScheme=Theme.of(context).colorScheme;
    return DraggableScrollableSheet(
      expand:false,
      initialChildSize:0.55,
      minChildSize:0.4,
      maxChildSize:0.85,
      builder:(ctx,sc)=>SingleChildScrollView(
        controller:sc,
        child:Padding(
          padding:const EdgeInsets.all(24),
          child:Column(
            children:
            [
              Container(
                width:40,
                height:4,
                decoration:BoxDecoration(
                  color:colorScheme.onSurfaceVariant.withOpacity(0.3),
                  borderRadius:BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height:24),
              Hero(
                tag:'avatar_${contact.name}',
                child:CircleAvatar(
                  radius:48,
                  backgroundColor:colorScheme.primaryContainer,
                  backgroundImage:NetworkImage(contact.avatarUrl),
                  onBackgroundImageError:(_, __) {},
                  child:null,
                ),
              ),
              const SizedBox(height:16),
              Text(contact.name,
                  style:const TextStyle(
                      fontSize:22,fontWeight:FontWeight.bold)),
              const SizedBox(height:24),
              _InfoRow(
                  icon:Icons.phone,label:'Phone',value:contact.phone),
              const Divider(),
              _InfoRow(
                  icon:Icons.email,label:'Email',value:contact.email),
              const SizedBox(height: 24),
              Row(
                children:
                [
                  Expanded(
                    child:FilledButton.icon(
                      onPressed:(){},
                      icon:const Icon(Icons.phone),
                      label:const Text('Call'),
                    ),
                  ),
                  const SizedBox(width:12),
                  Expanded(
                    child:OutlinedButton.icon(
                      onPressed:(){},
                      icon:const Icon(Icons.message),
                      label:const Text('Message'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
class _InfoRow extends StatelessWidget
{
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow({required this.icon,required this.label,required this.value});
  @override
  Widget build(BuildContext context)
  {
    return Padding(
      padding:const EdgeInsets.symmetric(vertical: 10),
      child:Row(
        children:
        [
          Icon(icon,color:Theme.of(context).colorScheme.primary),
          const SizedBox(width:16),
          Column(
            crossAxisAlignment:CrossAxisAlignment.start,
            children:
            [
              Text(label,
                  style:TextStyle(
                      fontSize:11,
                      color:Theme.of(context).colorScheme.onSurfaceVariant)),
              Text(value,
                  style:const TextStyle(
                      fontSize:15,fontWeight:FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }
}