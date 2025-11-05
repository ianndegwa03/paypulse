// lib/app/di/modules/web3_blockchain_module.dart
@module
abstract class Web3BlockchainModule {
  
  @singleton
  DeFiRepository get deFiRepository => DeFiRepositoryImpl();
  
  @singleton
  NFTRepository get nftRepository => NFTRepositoryImpl();
  
  @singleton
  Web3IdentityRepository get web3IdentityRepository => Web3IdentityRepositoryImpl();
  
  @singleton
  DeFiBloc get deFiBloc => DeFiBloc(
    stakeAssetsUseCase: getIt<StakeAssetsUseCase>(),
    provideLiquidityUseCase: getIt<ProvideLiquidityUseCase>(),
  );
  
  @singleton
  NFTBloc get nftBloc => NFTBloc(
    mintNFTUseCase: getIt<MintNFTUseCase>(),
    manageNFTPortfolioUseCase: getIt<ManageNFTPortfolioUseCase>(),
  );
}