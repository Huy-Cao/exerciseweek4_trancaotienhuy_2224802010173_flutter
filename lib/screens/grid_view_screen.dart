import 'package:flutter/material.dart';
class GridViewScreen extends StatelessWidget
{
  const GridViewScreen({super.key});
  static const List<IconData>_icons=
  [
    Icons.star,
    Icons.favorite,
    Icons.home,
    Icons.camera_alt,
    Icons.music_note,
    Icons.sports_soccer,
    Icons.local_pizza,
    Icons.flight,
    Icons.directions_car,
    Icons.pets,
    Icons.beach_access,
    Icons.wb_sunny,
  ];
  static const List<Color>_colors=
  [
    Color(0xFF6C63FF),
    Color(0xFFFF6584),
    Color(0xFF43C6AC),
    Color(0xFFF7971E),
    Color(0xFF56CCF2),
    Color(0xFF6FCF97),
    Color(0xFFEB5757),
    Color(0xFF9B51E0),
    Color(0xFF2F80ED),
    Color(0xFFF2994A),
    Color(0xFF27AE60),
    Color(0xFFE2B04A),
  ];
  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      appBar:AppBar(
        title:const Text('Exercise 2 — Grid View'),
        backgroundColor:Theme.of(context).colorScheme.surfaceContainer,
      ),
      body:SingleChildScrollView(
        padding:const EdgeInsets.all(16),
        child:Column(
          crossAxisAlignment:CrossAxisAlignment.start,
          children:
          [
            const _SectionTitle(title:'Fixed Column Grid'),
            const SizedBox(height:12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount:3,
              mainAxisSpacing:8,
              crossAxisSpacing:8,
              childAspectRatio:1,
              children:List.generate(12,(index)=>_GridItem(
                  icon:_icons[index],
                  color:_colors[index],
                  label:'Item ${index+1}',
                ),
              ),
            ),
            const SizedBox(height:32),
            const _SectionTitle(title:'Responsive Grid'),
            const SizedBox(height:12),
            GridView.extent(
              shrinkWrap:true,
              physics:const NeverScrollableScrollPhysics(),
              maxCrossAxisExtent:150,
              mainAxisSpacing:10,
              crossAxisSpacing:10,
              childAspectRatio:0.8,
              children:List.generate(
                12,(index)=>_GridItem(
                  icon:_icons[index],
                  color:_colors[(index+4)%_colors.length],
                  label:'Item ${index+1}',
                ),
              ),
            ),
            const SizedBox(height:16),
          ],
        ),
      ),
    );
  }
}
class _SectionTitle extends StatelessWidget
{
  final String title;
  const _SectionTitle({required this.title});
  @override
  Widget build(BuildContext context)
  {
    return Container(
      padding:const EdgeInsets.symmetric(horizontal:14,vertical:10),
      decoration:BoxDecoration(
        color:Theme.of(context).colorScheme.primaryContainer,
        borderRadius:BorderRadius.circular(10),
      ),
      child:Row(
        mainAxisSize:MainAxisSize.min,
        children:
        [
          Icon(Icons.grid_view,size:18,color:Theme.of(context).colorScheme.onPrimaryContainer),
          const SizedBox(width:8),
          Text(
            title,
            style:TextStyle(
              fontSize:15,
              fontWeight:FontWeight.bold,
              color:Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}
class _GridItem extends StatelessWidget
{
  final IconData icon;
  final Color color;
  final String label;
  const _GridItem({required this.icon,required this.color,required this.label});
  @override
  Widget build(BuildContext context)
  {
    return Container(
      decoration:BoxDecoration(
        color:color.withOpacity(0.15),
        borderRadius:BorderRadius.circular(16),
        border:Border.all(color:color.withOpacity(0.3)),
      ),
      child:Column(
        mainAxisAlignment:MainAxisAlignment.center,
        children:
        [
          Container(
            width:52,
            height:52,
            decoration:BoxDecoration(
              color:color.withOpacity(0.2),
              shape:BoxShape.circle,
            ),
            child:Icon(icon,color:color,size:28),
          ),
          const SizedBox(height:10),
          Text(
            label,
            style:TextStyle(
              fontSize:13,
              fontWeight:FontWeight.w600,
              color:color.withOpacity(0.85),
            ),
          ),
        ],
      ),
    );
  }
}