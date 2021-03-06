//
//  HTHomeViewController.m
//  HTKey
//
//  Created by iMac on 2017/12/29.
//  Copyright © 2017年 iMac. All rights reserved.
//

#import "HTHomeViewController.h"
#import "HTItemTableViewCell.h"
#import "HTItemDetailViewController.h"
#import "AppDelegate.h"

@interface HTHomeViewController ()<UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate>

@property(nonatomic, strong)UIButton        *addBtn;
@property(nonatomic, strong)UIButton        *searchBtn;
@property(nonatomic, strong)UITableView     *tableView;
@property(nonatomic, strong)UISearchBar     *searchBar;
@property(nonatomic, strong)NSMutableArray  *searchArray;
@property(nonatomic, assign)BOOL            inSearch;

@end

@implementation HTHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:self.searchBtn];
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:self.addBtn];
//    [self.view addSubview:self.tableView];
//    _inSearch = NO;
//    _searchArray = [NSMutableArray array];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

#pragma mark Selector

- (void)setInSearch:(BOOL)inSearch{
    _inSearch = inSearch;
    [self.tableView reloadData];
    if (_inSearch) {
        self.navigationItem.titleView = self.searchBar;
        self.navigationItem.leftBarButtonItem = nil;
        self.navigationItem.rightBarButtonItem = nil;
        [self.searchBar becomeFirstResponder];
    }else{
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:self.searchBtn];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:self.addBtn];
        self.navigationItem.titleView = nil;
    }
}



#pragma mark UITableView Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (_inSearch) {
        return _searchArray.count;
    }else{
        AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
        return app.items.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return FitFloat(70);
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_inSearch) {
        HTItemTableViewCell *cell = [HTItemTableViewCell cellWithTableView:tableView];
        cell.model = _searchArray[indexPath.row];
        return cell;
    }else{
        HTItemTableViewCell *cell = [HTItemTableViewCell cellWithTableView:tableView];
        AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
        cell.model = app.items[indexPath.row];
        return cell;
    }

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    HTItemDetailViewController *detailVC = [[HTItemDetailViewController alloc]init];
    if (_inSearch) {
        self.inSearch = NO;
        detailVC.model = _searchArray[indexPath.row];
    }else{
        AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
        detailVC.model = app.items[indexPath.row];
    }
    detailVC.edit = NO;
    detailVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:detailVC animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 删除模型
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [app.items removeObjectAtIndex:indexPath.row];
    // 刷新
    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
}


- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_inSearch) {
        return UITableViewCellEditingStyleNone;
    }else{
        return UITableViewCellEditingStyleDelete;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}


#pragma mark UISearchBar Delegate

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    self.inSearch = NO;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar{
    self.inSearch = NO;
    return YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    [_searchArray removeAllObjects];
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [app.items enumerateObjectsUsingBlock:^(HTItemModel *model, NSUInteger idx, BOOL * _Nonnull stop) {
        NSRange range_t = [model.title rangeOfString:searchText options:NSRegularExpressionSearch];
        BOOL titleOK = (range_t.location != NSNotFound)?YES:NO;
        NSRange range_a = [model.account rangeOfString:searchText options:NSRegularExpressionSearch];
        BOOL accountOK = (range_a.location != NSNotFound)?YES:NO;
        if (titleOK||accountOK) {
            [_searchArray addObject:model];
        }
    }];
    [self.tableView reloadData];
}

#pragma mark Getter

- (UITableView *)tableView{
    if (!_tableView) {
        CGRect frame = CGRectMake(0, 0, UI_WIDTH, TRUE_HEIGHT);
        _tableView = [[UITableView alloc]initWithFrame:frame style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [UIView new];
    }
    return _tableView;
}

- (UIButton *)searchBtn{
    if (!_searchBtn) {
        _searchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _searchBtn.frame = CGRectMake(0, 0, FitFloat(20), FitFloat(20));
        [_searchBtn setImage:[UIImage imageNamed:@"search"] forState:UIControlStateNormal];
        [_searchBtn bk_addEventHandler:^(id sender) {
            self.inSearch = YES;
        } forControlEvents:UIControlEventTouchDown];
    }
    return _searchBtn;
}

- (UIButton *)addBtn{
    if (!_addBtn) {
        _addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _addBtn.frame = CGRectMake(0, 0, FitFloat(20), FitFloat(20));
        [_addBtn setImage:[UIImage imageNamed:@"add"] forState:UIControlStateNormal];
        [_addBtn bk_addEventHandler:^(id sender) {
            HTItemModel *newModel = [[HTItemModel alloc]init];
            AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
            [app.items addObject:newModel];
            HTItemDetailViewController *detailVC = [[HTItemDetailViewController alloc]init];
            detailVC.hidesBottomBarWhenPushed = YES;
            detailVC.edit = YES;
            detailVC.model = newModel;
            [self.navigationController pushViewController:detailVC animated:YES];
        } forControlEvents:UIControlEventTouchDown];
    }
    return _addBtn;
}

- (UISearchBar *)searchBar{
    if (!_searchBar) {
        _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, UI_WIDTH, kNavBarHeight)];
        [[UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[UISearchBar class]]] setTitle:@"取消"];
        _searchBar.showsCancelButton = YES;
        _searchBar.delegate = self;
    }
    return _searchBar;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
