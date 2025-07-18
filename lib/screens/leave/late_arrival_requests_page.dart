import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/late_arrival_provider.dart';
import '../../data/models/late_arrival_request_model.dart';
import '../../styles/colors.dart';
import '../../widgets/custom_button.dart';
import 'package:intl/intl.dart';

class LateArrivalRequestsPage extends StatefulWidget {
  const LateArrivalRequestsPage({Key? key}) : super(key: key);

  @override
  State<LateArrivalRequestsPage> createState() => _LateArrivalRequestsPageState();
}

class _LateArrivalRequestsPageState extends State<LateArrivalRequestsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LateArrivalProvider>().getMyRequests(refresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Permohonan Keterlambatan',
          style: TextStyle(
            fontSize: 20, 
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),

      ),
      body: Consumer<LateArrivalProvider>(
        builder: (context, provider, child) {
          return RefreshIndicator(
            onRefresh: () => provider.getMyRequests(refresh: true),
            color: AppColors.primary,
            child: Column(
              children: [
                // Statistics Card
                _buildStatisticsCard(provider),
                
                // Requests List
                Expanded(
                  child: _buildRequestsList(provider),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreateRequest,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildStatisticsCard(LateArrivalProvider provider) {
    final stats = provider.getStatistics();
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Statistik Permohonan',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Total',
                  stats['total']?.toString() ?? '0',
                  AppColors.primary,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Menunggu',
                  stats['pending']?.toString() ?? '0',
                  AppColors.warning,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Disetujui',
                  stats['approved']?.toString() ?? '0',
                  AppColors.success,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Ditolak',
                  stats['rejected']?.toString() ?? '0',
                  AppColors.error,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildRequestsList(LateArrivalProvider provider) {
    if (provider.isLoading && provider.requests.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (provider.errorMessage != null && provider.requests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.textHint,
            ),
            const SizedBox(height: 16),
            Text(
              provider.errorMessage!,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            CustomButton(
              text: 'Coba Lagi',
              onPressed: () => provider.getMyRequests(refresh: true),
              width: 120,
            ),
          ],
        ),
      );
    }

    if (provider.requests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.schedule,
              size: 64,
              color: AppColors.textHint,
            ),
            const SizedBox(height: 16),
            Text(
              'Belum ada permohonan keterlambatan',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            CustomButton(
              text: 'Buat Permohonan',
              onPressed: _navigateToCreateRequest,
              width: 150,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      itemCount: provider.requests.length + (provider.hasMoreData ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == provider.requests.length) {
          // Load more indicator
          if (provider.isLoading) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          } else {
            // Load more button
            return Padding(
              padding: const EdgeInsets.all(16),
              child: CustomButton(
                text: 'Muat Lebih Banyak',
                onPressed: () => provider.getMyRequests(),
              ),
            );
          }
        }

        final request = provider.requests[index];
        return _buildRequestCard(request, provider);
      },
    );
  }

  Widget _buildRequestCard(LateArrivalRequest request, LateArrivalProvider provider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _showRequestDetails(request),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DateFormat('EEEE, dd MMMM yyyy', 'id_ID')
                                .format(request.tanggalTerlambat),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Jam rencana: ${request.formattedTime}',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildStatusBadge(request.status),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  request.alasan,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: AppColors.textHint,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Diajukan ${DateFormat('dd/MM/yyyy HH:mm').format(request.createdAt)}',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textHint,
                      ),
                    ),
                    if (request.approvedAt != null) ...[
                      const SizedBox(width: 16),
                      Icon(
                        Icons.check_circle_outline,
                        size: 14,
                        color: AppColors.success,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Disetujui ${DateFormat('dd/MM/yyyy').format(request.approvedAt!)}',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ],
                ),
                
                // Delete button for pending requests
                
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color backgroundColor;
    Color textColor;
    String text;

    switch (status) {
      case 'pending':
        backgroundColor = AppColors.warningLight;
        textColor = AppColors.warning;
        text = 'Menunggu';
        break;
      case 'approved':
        backgroundColor = AppColors.successLight;
        textColor = AppColors.success;
        text = 'Disetujui';
        break;
      case 'rejected':
        backgroundColor = AppColors.errorLight;
        textColor = AppColors.error;
        text = 'Ditolak';
        break;
      default:
        backgroundColor = AppColors.infoLight;
        textColor = AppColors.info;
        text = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
    );
  }

  void _navigateToCreateRequest() async {
    final result = await context.push('/create-late-arrival-request');

    if (result == true) {
      // Refresh the list if a new request was created successfully
      if (mounted) {
        context.read<LateArrivalProvider>().getMyRequests(refresh: true);
      }
    }
  }

  void _showRequestDetails(LateArrivalRequest request) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildRequestDetailsSheet(request),
    );
  }

  Widget _buildRequestDetailsSheet(LateArrivalRequest request) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Title
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Detail Permohonan',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                _buildStatusBadge(request.status),
              ],
            ),
            const SizedBox(height: 20),
            
            // Details
            _buildDetailItem('Tanggal', DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(request.tanggalTerlambat)),
            _buildDetailItem('Jam Rencana', request.formattedTime),
            _buildDetailItem('Alasan', request.alasan),
            _buildDetailItem('Diajukan', DateFormat('dd/MM/yyyy HH:mm').format(request.createdAt)),
            
            if (request.approvedBy != null)
              _buildDetailItem('Disetujui oleh', request.approvedBy!),
            
            if (request.approvedAt != null)
              _buildDetailItem('Tanggal persetujuan', DateFormat('dd/MM/yyyy HH:mm').format(request.approvedAt!)),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const Text(': '),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(LateArrivalRequest request, LateArrivalProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Permohonan'),
        content: const Text('Apakah Anda yakin ingin menghapus permohonan ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await provider.deleteLateArrivalRequest(request.id);
              
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success 
                        ? 'Permohonan berhasil dihapus'
                        : provider.errorMessage ?? 'Gagal menghapus permohonan',
                    ),
                    backgroundColor: success ? Colors.green : Colors.red,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}
