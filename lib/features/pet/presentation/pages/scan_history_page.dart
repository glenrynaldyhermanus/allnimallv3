import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/widgets.dart';
import '../providers/pet_providers.dart';

class ScanHistoryPage extends ConsumerStatefulWidget {
  final String petId;

  const ScanHistoryPage({super.key, required this.petId});

  @override
  ConsumerState<ScanHistoryPage> createState() => _ScanHistoryPageState();
}

class _ScanHistoryPageState extends ConsumerState<ScanHistoryPage> {
  GoogleMapController? _mapController;
  bool _showMap = true;

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final logsAsync = ref.watch(scanLogsProvider(widget.petId));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppStrings.scanHistory,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: Icon(_showMap ? Icons.list : Icons.map),
            onPressed: () => setState(() => _showMap = !_showMap),
          ),
        ],
      ),
      body: logsAsync.when(
        data: (logs) {
          if (logs.isEmpty) {
            return const EmptyState(
              icon: Icons.location_on,
              title: AppStrings.noScans,
              message: 'Belum ada yang memindai QR code hewan ini',
            );
          }

          // Filter logs with location
          final logsWithLocation = logs
              .where((log) => log.hasLocation)
              .toList();

          if (_showMap && logsWithLocation.isNotEmpty) {
            return _buildMapView(logsWithLocation);
          } else {
            return _buildListView(logs);
          }
        },
        loading: () => const Center(child: LoadingIndicator()),
        error: (error, stack) => ErrorState(
          message: error.toString(),
          onRetry: () => ref.refresh(scanLogsProvider(widget.petId)),
        ),
      ),
    );
  }

  Widget _buildMapView(List logs) {
    // Create markers from scan logs
    final markers = logs.asMap().entries.map((entry) {
      final index = entry.key;
      final log = entry.value;
      return Marker(
        markerId: MarkerId(log.id),
        position: LatLng(log.latitude!, log.longitude!),
        infoWindow: InfoWindow(
          title: 'Scan #${index + 1}',
          snippet: log.timeAgo,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          index == 0 ? BitmapDescriptor.hueRed : BitmapDescriptor.hueViolet,
        ),
      );
    }).toSet();

    // Get center position (latest scan)
    final latestLog = logs.first;
    final initialPosition = LatLng(latestLog.latitude!, latestLog.longitude!);

    return GoogleMap(
      initialCameraPosition: CameraPosition(target: initialPosition, zoom: 14),
      markers: markers,
      onMapCreated: (controller) => _mapController = controller,
      myLocationButtonEnabled: true,
      myLocationEnabled: true,
      zoomControlsEnabled: true,
      mapToolbarEnabled: true,
    );
  }

  Widget _buildListView(List logs) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppDimensions.paddingMd),
      itemCount: logs.length,
      itemBuilder: (context, index) {
        final log = logs[index];
        return AppCard(
          margin: const EdgeInsets.only(bottom: AppDimensions.marginMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppDimensions.paddingSm),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusSm,
                      ),
                    ),
                    child: Icon(
                      log.hasLocation ? Icons.location_on : Icons.location_off,
                      color: log.hasLocation
                          ? AppColors.primary
                          : AppColors.grey,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spaceMd),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          log.locationDisplay,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AppDimensions.spaceXs),
                        Row(
                          children: [
                            const Icon(
                              Icons.access_time,
                              size: 14,
                              color: AppColors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              log.timeAgo,
                              style: GoogleFonts.nunito(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        if (log.locationAccuracy != null)
                          Text(
                            'Akurasi: ${log.locationAccuracy!.toStringAsFixed(0)}m',
                            style: GoogleFonts.nunito(
                              fontSize: 10,
                              color: AppColors.textSecondary,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (log.hasLocation)
                    IconButton(
                      icon: const Icon(Icons.open_in_new),
                      onPressed: () {
                        // TODO: Open in Google Maps
                      },
                    ),
                ],
              ),

              // Device Info
              if (log.deviceInfo != null && log.deviceInfo!.isNotEmpty) ...[
                const SizedBox(height: AppDimensions.spaceMd),
                const Divider(),
                const SizedBox(height: AppDimensions.spaceSm),
                Text(
                  'Device Info',
                  style: GoogleFonts.nunito(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  log.userAgent ?? 'Unknown device',
                  style: GoogleFonts.nunito(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
