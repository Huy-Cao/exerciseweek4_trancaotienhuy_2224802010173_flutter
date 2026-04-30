class Contact {
  final String name;
  final String phone;
  final String email;
  final String avatarUrl;

  const Contact({
    required this.name,
    required this.phone,
    required this.email,
    required this.avatarUrl,
  });

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }
}

final List<Contact> sampleContacts = [
  const Contact(
    name: 'Alice Nguyen',
    phone: '0901 234 567',
    email: 'alice.nguyen@email.com',
    avatarUrl: 'https://i.pravatar.cc/150?img=1',
  ),
  const Contact(
    name: 'Bob Tran',
    phone: '0912 345 678',
    email: 'bob.tran@email.com',
    avatarUrl: 'https://i.pravatar.cc/150?img=3',
  ),
  const Contact(
    name: 'Charlie Le',
    phone: '0923 456 789',
    email: 'charlie.le@email.com',
    avatarUrl: 'https://i.pravatar.cc/150?img=5',
  ),
  const Contact(
    name: 'Diana Pham',
    phone: '0934 567 890',
    email: 'diana.pham@email.com',
    avatarUrl: 'https://i.pravatar.cc/150?img=9',
  ),
  const Contact(
    name: 'Edward Vo',
    phone: '0945 678 901',
    email: 'edward.vo@email.com',
    avatarUrl: 'https://i.pravatar.cc/150?img=12',
  ),
  const Contact(
    name: 'Fiona Ho',
    phone: '0956 789 012',
    email: 'fiona.ho@email.com',
    avatarUrl: 'https://i.pravatar.cc/150?img=16',
  ),
  const Contact(
    name: 'George Bui',
    phone: '0967 890 123',
    email: 'george.bui@email.com',
    avatarUrl: 'https://i.pravatar.cc/150?img=20',
  ),
  const Contact(
    name: 'Helen Dang',
    phone: '0978 901 234',
    email: 'helen.dang@email.com',
    avatarUrl: 'https://i.pravatar.cc/150?img=25',
  ),
  const Contact(
    name: 'Ivan Nguyen',
    phone: '0989 012 345',
    email: 'ivan.nguyen@email.com',
    avatarUrl: 'https://i.pravatar.cc/150?img=33',
  ),
  const Contact(
    name: 'Jenny Mai',
    phone: '0990 123 456',
    email: 'jenny.mai@email.com',
    avatarUrl: 'https://i.pravatar.cc/150?img=44',
  ),
  const Contact(
    name: 'Kevin Luu',
    phone: '0901 234 111',
    email: 'kevin.luu@email.com',
    avatarUrl: 'https://i.pravatar.cc/150?img=52',
  ),
  const Contact(
    name: 'Lily Cao',
    phone: '0912 345 222',
    email: 'lily.cao@email.com',
    avatarUrl: 'https://i.pravatar.cc/150?img=60',
  ),
];