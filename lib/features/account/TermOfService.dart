import 'package:flutter/material.dart';

class TermsOfServicePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chính Sách Sử Dụng'),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Chính Sách Sử Dụng của TubeTube',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Text(
              '1. Giới thiệu\n\n'
                  'Chào mừng bạn đến với TubeTube! TubeTube là ứng dụng chia sẻ video cho phép người dùng tải lên, xem, thích, xóa video và tương tác với nội dung trong cộng đồng. Khi sử dụng ứng dụng, bạn đồng ý với các điều khoản và điều kiện dưới đây.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              '2. Điều khoản chung\n\n'
                  '- Bạn phải có ít nhất 13 tuổi để sử dụng TubeTube.\n'
                  '- Bạn đồng ý không tải lên hoặc chia sẻ các video vi phạm quyền sở hữu trí tuệ của người khác, bao gồm nhưng không giới hạn ở bản quyền, nhãn hiệu, và quyền sở hữu.\n'
                  '- Chúng tôi có quyền sửa đổi hoặc ngừng dịch vụ mà không cần thông báo trước.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              '3. Quyền sở hữu trí tuệ\n\n'
                  '- Tất cả nội dung trong ứng dụng, bao gồm video, hình ảnh, âm thanh, và phần mềm, là tài sản của TubeTube hoặc các bên cấp phép.\n'
                  '- Bạn phải có quyền sở hữu hoặc quyền sử dụng hợp pháp đối với các video bạn tải lên.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              '4. Quyền và nghĩa vụ của người dùng\n\n'
                  '- Bạn có quyền tải lên video, xem video, thích video, và bình luận về video.\n'
                  '- Bạn có trách nhiệm về nội dung video của mình và đảm bảo không vi phạm các luật pháp liên quan, bao gồm các quy định về bản quyền và quyền riêng tư.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              '5. Dữ liệu người dùng\n\n'
                  '- Chúng tôi thu thập và lưu trữ một số dữ liệu cá nhân để cung cấp dịch vụ tốt hơn, như thông tin đăng ký và hoạt động của bạn trong ứng dụng.\n'
                  '- Dữ liệu của bạn sẽ được xử lý theo Chính Sách Bảo Mật của chúng tôi.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              '6. Quản lý tài khoản\n\n'
                  '- Bạn có thể tạo tài khoản bằng cách đăng ký qua email hoặc tài khoản mạng xã hội.\n'
                  '- Bạn có trách nhiệm bảo vệ tài khoản của mình và không chia sẻ mật khẩu với người khác.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              '7. Giới hạn trách nhiệm\n\n'
                  '- TubeTube không chịu trách nhiệm về bất kỳ thiệt hại nào phát sinh từ việc sử dụng hoặc không thể sử dụng ứng dụng.\n'
                  '- Chúng tôi không chịu trách nhiệm về nội dung video do người dùng tải lên và không đảm bảo tính chính xác, đầy đủ của video.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              '8. Quyền thay đổi điều khoản\n\n'
                  '- TubeTube có thể cập nhật các điều khoản và điều kiện sử dụng vào bất kỳ lúc nào mà không cần thông báo trước.\n'
                  '- Bạn nên thường xuyên kiểm tra các điều khoản sử dụng để nắm bắt các thay đổi.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              '9. Liên hệ\n\n'
                  'Nếu bạn có bất kỳ câu hỏi nào về chính sách sử dụng của TubeTube, vui lòng liên hệ với chúng tôi qua email [huytruonggl81@gmail.com].',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

